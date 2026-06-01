#!/bin/bash

# Script de despliegue automático para la infraestructura ThingsBoard + Modbus
echo "========================================================"
echo " Iniciando despliegue de infraestructura ThingsBoard..."
echo "========================================================"

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Verificar dependencias
if ! command_exists docker; then
    echo "[ERROR] Docker no está instalado. Por favor, instálalo antes de continuar."
    exit 1
fi

if ! command_exists docker compose; then
    echo "[ERROR] Docker Compose no está instalado o no es compatible (se requiere la versión plugin 'docker compose')."
    exit 1
fi

# 2. Crear volúmenes persistentes si no existen
echo -e "\n[1/3] Verificando volúmenes persistentes..."

VOLUMES=("infra_thingsboard_tb_data" "infra_thingsboard_tb_log" "infra_thingsboard_tb_gw_logs")

for VOL in "${VOLUMES[@]}"; do
    if docker volume ls | grep -q "$VOL"; then
        echo "  - El volumen '$VOL' ya existe."
    else
        echo "  - Creando volumen '$VOL'..."
        docker volume create "$VOL"
    fi
done

# 3. Levantar los contenedores
echo -e "\n[2/3] Levantando contenedores con Docker Compose..."
if docker compose up -d; then
    echo -e "\n[3/3] ¡Despliegue completado con éxito!"
    echo "========================================================"
    echo "Estado de los contenedores:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "thingsboard|tb-gateway|NAMES"
    
    echo "========================================================"
    echo "Siguientes pasos:"
    echo "1. Ejecuta tu simulador Modbus en el host (puerto 502)."
    echo "2. Accede a ThingsBoard en http://localhost:8080"
    echo "   - Usuario Tenant: tenant@thingsboard.org / sysadmin"
    echo "   - Usuario Admin: sysadmin@thingsboard.org / sysadmin"
    echo "3. Revisa los logs del Gateway con: docker logs -f tb-gateway"
    echo "========================================================"
else
    echo -e "\n[ERROR] Ocurrió un problema al levantar los contenedores."
    exit 1
fi
