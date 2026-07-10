#!/bin/bash
# Genera el certificado autofirmado y las credenciales de autenticacion basica.
# Se ejecuta ANTES del build. Los archivos generados NO se versionan en git
# (contienen material sensible: clave privada y hash de contrasena).
set -e
cd "$(dirname "$0")"

mkdir -p certs auth

echo "== Generando certificado x.509 autofirmado =="
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/server.key -out certs/server.crt \
  -subj "/C=EC/ST=Pichincha/L=Quito/O=UNIR/OU=CasoPractico2/CN=casopractico2.local"

echo "== Generando credenciales de autenticacion basica (usuario: admin) =="
podman run --rm docker.io/httpd:latest htpasswd -bn admin "12345678" > auth/.htpasswd

echo "Listo. Archivos generados en certs/ y auth/ (no versionados)."
