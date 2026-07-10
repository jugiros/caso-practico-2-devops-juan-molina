#!/bin/bash
# ============================================================
# Caso Practico 2 - Script maestro de despliegue
# Uso:
#   ./deploy.sh          -> despliega toda la infraestructura y las apps
#   ./deploy.sh destroy  -> destruye toda la infraestructura
# Requisitos: az login activo, terraform, ansible (con venv activado
# o colecciones instaladas), ssh, scp.
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MODE="${1:-apply}"

if [ "$MODE" == "destroy" ]; then
  echo "=============================================="
  echo " Destruyendo toda la infraestructura"
  echo "=============================================="
  cd terraform
  terraform destroy -auto-approve
  echo "Infraestructura destruida."
  exit 0
fi

echo "=============================================="
echo " 1/6 - Terraform: creando infraestructura"
echo "=============================================="
cd terraform
terraform init -input=false
terraform apply -auto-approve

ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)
ACR_USERNAME=$(terraform output -raw acr_login_server | cut -d'.' -f1)
VM_IP=$(terraform output -raw vm_public_ip)
cd "$SCRIPT_DIR"

echo "=============================================="
echo " 2/6 - Copiando codigo fuente de las apps a la VM"
echo "=============================================="
# Se espera a que la VM termine de arrancar completamente (cloud-init)
sleep 30
scp -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_vm -r app-podman azureuser@"$VM_IP":~/
scp -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_vm -r app-k8s azureuser@"$VM_IP":~/

echo "=============================================="
echo " 3/6 - Ansible: desplegando App A (Podman)"
echo "=============================================="
cd ansible
cat > hosts << HOSTS
[vm_podman]
vm-casopractico2 ansible_host=$VM_IP ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/id_rsa_vm
HOSTS
ansible-playbook -i hosts playbook-vm-podman.yml

echo "=============================================="
echo " 4/6 - Construyendo y subiendo la imagen de App B (en la VM, arquitectura ARM64)"
echo "=============================================="
ACR_PASSWORD=$(grep acr_admin_password group_vars/all.yml | cut -d'"' -f2)
ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_vm azureuser@"$VM_IP" bash -s <<REMOTE
set -e
cd ~/app-k8s
sudo podman build -t appb-k8s:casopractico2 .
sudo podman login $ACR_LOGIN_SERVER -u $ACR_USERNAME -p '$ACR_PASSWORD'
sudo podman tag appb-k8s:casopractico2 $ACR_LOGIN_SERVER/appb/webserver-k8s:casopractico2
sudo podman push $ACR_LOGIN_SERVER/appb/webserver-k8s:casopractico2
REMOTE

echo "=============================================="
echo " 5/6 - Ansible: configurando AKS y desplegando App B"
echo "=============================================="
ansible-playbook playbook-k8s-app.yml

echo "=============================================="
echo " 6/6 - Resumen del despliegue"
echo "=============================================="
cd "$SCRIPT_DIR/terraform"
echo "App A (Podman):    https://$(terraform output -raw vm_public_ip)/  (usuario: admin / clave: 12345678)"
export KUBECONFIG="$SCRIPT_DIR/ansible/kubeconfig-casopractico2"
APPB_IP=$(kubectl get svc -n casopractico2 appb-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pendiente, ejecuta: kubectl get svc -n casopractico2")
echo "App B (Kubernetes): http://$APPB_IP/"
echo "=============================================="
echo " Despliegue completo."
echo "=============================================="
