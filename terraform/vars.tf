variable "location" {
  type        = string
  description = "Region de Azure donde se despliega toda la infraestructura"
  default     = "westeurope"
}

variable "public_key_path" {
  type        = string
  description = "Ruta a la clave publica SSH para acceso a la VM"
  default     = "~/.ssh/id_rsa_vm.pub"
}

variable "ssh_user" {
  type        = string
  description = "Usuario administrador para SSH en la VM"
  default     = "azureuser"
}

variable "vm_size" {
  type        = string
  description = "Tamano de la VM Linux para Podman"
  default     = "Standard_B2s_v2"
}

variable "aks_node_vm_size" {
  type        = string
  description = "Tamano del nodo worker del cluster AKS"
  default     = "Standard_B2s_v2"
}

variable "registry_name" {
  type        = string
  description = "Nombre base del Azure Container Registry"
  default     = "acrcasopractico2"
}

variable "registry_sku" {
  type        = string
  description = "SKU del ACR: Basic, Standard o Premium"
  default     = "Basic"
}
