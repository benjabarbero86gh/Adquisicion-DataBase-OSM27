# Guía de Despliegue: Infraestructura ThingsBoard y Gateway Modbus

Esta guía detalla los pasos para levantar la infraestructura de recolección de datos y verificar la ingesta de telemetría proveniente del simulador Modbus TCP del reconectador OSM27.

## 1. Ejecución del Simulador (Host)
Recuerda que el simulador Modbus no corre en un contenedor Docker en este despliegue, sino que debe ejecutarse mediante su ejecutable o script (por ejemplo, `python main.py` en el host) escuchando en el puerto `502`. Asegúrate de que esté en ejecución antes de levantar la infraestructura.

## 2. Ejecución del Entorno Docker
Para levantar los servicios de ThingsBoard y el IoT Gateway, sitúate en este mismo directorio (donde se encuentra el archivo `docker-compose.yml`) y ejecuta el siguiente comando:

```bash
docker compose up -d
```
Esto descargará las imágenes necesarias y levantará los contenedores `thingsboard` y `tb-gateway` en segundo plano dentro de la red aislada `tb_net`.

## 3. Asegurar la Conexión MQTT (Puerto 1883)
El `tb-gateway` necesita comunicarse con la plataforma ThingsBoard mediante MQTT. El `docker-compose.yml` ya asegura que ThingsBoard exporte el puerto `1883` para posibles conexiones externas, y en la red interna se comunicarán por dicho puerto.
Para confirmar que el Gateway se conectó al broker MQTT de ThingsBoard:

1. Revisa los logs de conexión del contenedor Gateway:
   ```bash
   docker logs -f tb-gateway
   ```
2. Debes buscar líneas que confirmen la conexión al broker.

## 4. Verificación de la Ingesta de Telemetría Modbus
El conector Modbus consultará al simulador expuesto en `host.docker.internal:502` según el mapeo del archivo `config/modbus.json`.

1. Mantén la vista en los logs del Gateway filtrando por el conector Modbus:
   ```bash
   docker logs -f tb-gateway | grep -i modbus
   ```
2. Un funcionamiento correcto producirá logs indicando "Data published" con las métricas recibidas.

## 5. Acceso a la Interfaz Web
Accede a la Interfaz Gráfica abriendo tu navegador en:
**http://localhost:8080**

Credenciales por defecto:
- **Tenant Administrator**: `tenant@thingsboard.org` / `sysadmin`
- **System Administrator**: `sysadmin@thingsboard.org` / `sysadmin`

En el panel de **Devices**, verás aprovisionado automáticamente el `OSM27_Recloser`.
