#!/bin/bash

# Generar un token aleatorio de 32 caracteres
TOKEN=$(openssl rand -hex 32)

echo "Token generado para APM:"
echo "$TOKEN"
echo ""
echo "Copia este token en tu archivo .env como valor de APM_SECRET_TOKEN"
echo ""
echo "Ejemplo de archivo .env:"
echo "STACK_VERSION=8.11.0"
echo "ELASTIC_PASSWORD=changeme"
echo "KIBANA_SYSTEM_PASSWORD=changeme"
echo "APM_SECRET_TOKEN=$TOKEN"
