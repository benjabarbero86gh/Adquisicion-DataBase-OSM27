# Infraestructura IoT y Telemetría: ThingsBoard + Modbus TCP

Este directorio contiene la infraestructura de despliegue basada en contenedores Docker para la ingesta, procesamiento y visualización de telemetría industrial (Modbus TCP) utilizando ThingsBoard.

## 📁 Estructura del Proyecto

El proyecto está organizado siguiendo los estándares de la industria para separar documentación, configuración y esquemas:

- **`config/`**: Archivos JSON de configuración del ThingsBoard IoT Gateway (mapeo Modbus, configuración MQTT, etc.).
- **`docs/`**: Documentación técnica detallada, análisis del protocolo Modbus y guías de arquitectura.
- **`docker-compose.yml`**: Orquestador principal de la infraestructura.
- **`deploy.sh`**: Script bash de inicialización automatizada.

## 🚀 Guía Rápida de Despliegue

Sigue estos pasos para levantar toda la infraestructura desde cero:

### 1. Requisitos Previos
- Docker y Docker Compose instalados.
- El simulador Modbus en Python ejecutándose en el equipo local (Host) en el puerto TCP `502`.

### 2. Levantar la Infraestructura Automáticamente
En lugar de crear los volúmenes a mano, utiliza el script proporcionado en la raíz:

```bash
chmod +x deploy.sh
./deploy.sh
```
*(Este script verificará las dependencias, creará los volúmenes persistentes y ejecutará `docker compose up -d` de manera segura).*

### 3. Configuración del Token del Gateway
Antes de que el Gateway pueda enviar datos, debes aprovisionarlo en la plataforma y asignarle un token.
En el archivo `config/tb_gateway.json` verás que el token por defecto es `"TU_TOKEN_DE_ACCESO_AQUI"`. Sigue los pasos de la sección de acceso para crear el Gateway y colocarle este token.

> **[❗] IMPORTANTE: FRAMING DEL PROTOCOLO MODBUS TCP**
> Este proyecto se integra con un simulador que implementa **Modbus TCP Estándar** (con cabecera MBAP). Si necesitas realizar ajustes manuales en el archivo `config/modbus.json`, asegúrate imperativamente de que el parámetro de conexión sea `"method": "socket"` (o simplemente omítelo). **Nunca** utilices `"method": "rtu"`, ya que esto enviaría tramas RTU crudas por TCP; el servidor Modbus Python estándar no entenderá el formato y descartará la conexión en silencio, causando bloqueos por TimeOut en el Gateway.

## 🔐 Acceso y Configuración en ThingsBoard

Una vez que los contenedores estén activos, ingresa a la interfaz web:
🔗 **URL:** http://localhost:8080

**Credenciales Obligatorias (Tenant Administrator)**
Para gestionar dispositivos, **debes** iniciar sesión con este rol. *(Nota: El rol System Administrator no tiene permisos para crear o visualizar dispositivos).*
- **Usuario:** `tenant@thingsboard.org`
- **Contraseña:** `tenant`

### Paso a Paso: Vincular el Gateway

1. En el panel izquierdo de la web, ve a la sección **Entities -> Devices**.
2. Haz clic en el ícono `+` y selecciona **Add new device**.
3. Nómbralo como prefieras (ej. `Gateway Local`). **¡Importante!** Marca la casilla que dice **Is gateway**. Haz clic en **Add**.
4. Haz clic en el dispositivo que acabas de crear y selecciona **Manage credentials**.
5. Copia el **Access token** que aparece allí (o crea uno personalizado).
6. Pega ese token en tu archivo local `config/tb_gateway.json` reemplazando `"TU_TOKEN_DE_ACCESO_AQUI"`.
7. Reinicia el Gateway en tu terminal para que tome el nuevo token:
   ```bash
   docker restart tb-gateway
   ```

### Verificación y Auto-Aprovisionamiento del Reconectador
Con el Gateway correctamente vinculado, este aprovisionará automáticamente el dispositivo Modbus simulado (`OSM27_Recloser`).

1. Vuelve a la lista de **Devices** en ThingsBoard.
2. Verás que apareció automáticamente el dispositivo **`OSM27_Recloser`**.
3. Haz clic en él y navega a la pestaña **Latest Telemetry** para inspeccionar las mediciones eléctricas y variables de estado en tiempo real.

---
*Si deseas profundizar en la ingeniería del mapa de registros, la matriz de trazabilidad o la arquitectura del simulador, consulta los documentos Markdown en la carpeta `docs/`.*
