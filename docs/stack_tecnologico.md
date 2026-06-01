# Stack Tecnológico de la Solución de Telemetría (ThingsBoard IoT)

Este documento detalla el **Stack Tecnológico** empleado en la solución de adquisición, procesamiento y visualización de telemetría industrial. Está diseñado específicamente para servir como guía de integración al acoplar esta infraestructura con el **simulador desarrollado por un compañero** (u otro simulador de terceros), sustituyendo el simulador por defecto provisto en este repositorio.

---

## 1. Diagrama de Arquitectura de Integración

En esta solución, los componentes están completamente desacoplados. Esto permite que el simulador por defecto pueda ser reemplazado fácilmente por cualquier otro simulador Modbus TCP, siempre y cuando se configure adecuadamente el Gateway de enlace.

```mermaid
flowchart TD
    subgraph "Entorno del Compañero (Simulador Alternativo)"
        sim_comp["Simulador Modbus TCP de Terceros<br><b>(Modbus TCP Server / Slave)</b>"]
    end

    subgraph "Infraestructura ThingsBoard (Red Docker - tb_net)"
        gate["ThingsBoard IoT Gateway<br><b>(Modbus TCP Client / Master)</b>"]
        tb["Plataforma ThingsBoard<br><b>(Servidor de Aplicación e Ingesta)</b>"]
        db[("Base de Datos<br>(PostgreSQL)")]
        
        gate -->|MQTT / SSL (Puerto 1883)| tb
        tb <--> db
    end

    subgraph "Acceso y Consumo Externo (Host)"
        web["Navegador Web (UI de Control / Dashboard)"]
        web -->|HTTP (Puerto 8080)| tb
    end

    sim_comp -.->|Conexión Modbus TCP<br>Lectura de Registros (FC 2 / FC 4)| gate

    style sim_comp fill:#fff3e0,stroke:#ff9800,stroke-width:2px
    style gate fill:#ede7f6,stroke:#673ab7,stroke-width:2px
    style tb fill:#e8f5e9,stroke:#4caf50,stroke-width:2px
    style db fill:#eceff1,stroke:#607d8b,stroke-width:2px
    style web fill:#fffde7,stroke:#fbc02d,stroke-width:2px
```

---

## 2. Detalle del Stack Tecnológico

La solución prescinde de scripts de adquisición monolíticos a favor de una arquitectura basada en microservicios industriales estándar. Los componentes clave del stack son:

### A. ThingsBoard IoT Gateway (Middleware de Adquisición)
*   **Tecnología:** [ThingsBoard IoT Gateway](https://thingsboard.io/docs/iot-gateway/what-is-iot-gateway/) (`thingsboard/tb-gateway:latest`).
*   **Función:** Actúa como cliente **Modbus TCP Master**. Realiza peticiones cíclicas de lectura al simulador (que debe actuar como **Modbus TCP Slave**), empaqueta las respuestas en formato estructurado JSON y las publica mediante protocolo MQTT hacia el broker de la plataforma ThingsBoard.
*   **Características Clave:**
    *   **Conector Modbus Integrado:** Mapeo declarativo en JSON sin necesidad de programar código.
    *   **Auto-aprovisionamiento:** Registra dinámicamente nuevos dispositivos en ThingsBoard al detectar actividad en las direcciones configuradas.
    *   **Reconexión Automática:** Gestión robusta de timeouts y reintentos ante desconexiones del simulador.

### B. Plataforma IoT ThingsBoard (Servidor de Ingesta y Dashboarding)
*   **Tecnología:** [ThingsBoard Community Edition](https://thingsboard.io/) (`thingsboard/tb-postgres:latest`).
*   **Función:** Concentrador centralizado de la solución. Maneja la autenticación de dispositivos, la ingesta y persistencia de datos históricos, la ejecución de reglas de negocio (*Rule Engine*) y la renderización en tiempo real de Dashboards interactivos.
*   **Base de Datos Integrada:** PostgreSQL para el almacenamiento eficiente de metadatos de entidades y series temporales (*timeseries*).
*   **Protocolo de Enlace Interno:** MQTT en el puerto estándar `1883`, autenticado mediante Tokens de Acceso asignados al Gateway.

### C. Docker & Docker Compose (Orquestación e Infraestructura)
*   **Tecnología:** Docker Engine + Docker Compose (V2+).
*   **Función:** Empaquetar y aislar la infraestructura de ThingsBoard y el Gateway en una red virtual común (`tb_net`), garantizando portabilidad absoluta en cualquier entorno Linux, Windows o macOS.
*   **Persistencia:** Empleo de volúmenes Docker (`tb_data`, `tb_log` y `tb_gw_logs`) para asegurar que las configuraciones y los datos de telemetría no se pierdan al reiniciar o actualizar los contenedores.

---

## 3. Requisitos para Integrar el Simulador del Compañero

Para integrar exitosamente un simulador diferente en esta infraestructura, es necesario asegurar la compatibilidad en dos niveles: **Red / Conectividad** y **Mapeo de Registros**.

### 1. Requisitos de Conectividad y Red

*   **Rol de Red:** El nuevo simulador debe actuar obligatoriamente como **Modbus TCP Server** (Slave) y escuchar en una interfaz de red accesible por el contenedor del Gateway.
*   **Parámetros de Configuración del Conector (`modbus.json`):**
    *   **`host`:** IP o nombre de host DNS donde se ejecuta el nuevo simulador. 
        *   *Nota de Integración:* Si el simulador corre en el sistema host (fuera de Docker) y el Gateway dentro de Docker, se puede utilizar la dirección IP de la interfaz puente de Docker (usualmente `172.17.0.1` o el alias `host.docker.internal` si está habilitado).
    *   **`port`:** Puerto TCP del simulador (típicamente `502`, o puertos alternativos como `5022`).
    *   **`unitId`:** Identificador Modbus del dispositivo (típicamente `1`).

### 2. Adaptación del Mapeo de Registros en `modbus.json`

El Gateway utiliza el archivo `infra_thingsboard/config/modbus.json` para interpretar los bytes binarios provenientes del simulador. Al cambiar de simulador, se debe **modificar este archivo** para adaptarlo al mapa de registros específico del compañero.

A continuación se detalla cómo configurar las directivas principales dentro del array `timeseries` de `modbus.json` según el tipo de dato que entregue el nuevo simulador:

#### A. Tipos de Datos Soportados y Configuración
| Tipo de Dato | Configuración en `modbus.json` | Descripción / Ejemplo |
| :--- | :--- | :--- |
| **Bits Individuales** (Coils o Discrete Inputs) | `"type": "bit"`, `"objectsCount": 1` | Indicado para alarmas, estados de interruptores y protecciones (FC 1 o FC 2). |
| **Enteros de 16 bits** | `"type": "16uint"` o `"16int"` | Registros de medición simple (FC 3 o FC 4). Permite escalar mediante `"multiplier"`. |
| **Enteros de 32 bits** (Doble Registro) | `"type": "32uint"`, `"objectsCount": 2` | Acumuladores de energía o valores grandes. Requiere definir orden de bytes y palabras. |
| **Flotantes de 32 bits** (IEEE 754) | `"type": "32float"`, `"objectsCount": 2` | Mediciones de alta precisión directo de simuladores modernos. |

#### B. Ejemplo de Adaptación en `modbus.json`
Si el simulador de tu compañero expone la *Tensión de Fase A* en el registro tipo **Input Register 30010** (dirección base `9`) como un entero sin signo de 16 bits que debe multiplicarse por `0.1` para obtener Voltios, la configuración en `modbus.json` deberá modificarse así:

```json
{
  "tag": "v_a_companero",
  "type": "16uint",
  "functionCode": 4,      // FC 4 = Read Input Registers (3xxxx)
  "objectsCount": 1,
  "address": 9,           // Dirección Modbus (Indexada en 0)
  "multiplier": 0.1       // Factor de escala (si aplica)
}
```

#### C. Control del Orden de Bytes y Palabras
Los datos multibyte (32 bits o más) varían según la arquitectura del simulador. El Gateway permite configurar esto globalmente o por tag mediante:
*   `"byteOrder": "BIG"` o `"LITTLE"`
*   `"wordOrder": "BIG"` o `"LITTLE"`
*(Asegúrate de coordinar este parámetro con tu compañero para evitar lecturas incoherentes de mediciones acumuladas de energía).*

---

## 4. Resumen Técnico del Stack (Especificaciones Rápidas)

| Componente | Tecnología | Versión Utilizada / Imagen | Puerto Interno | Puerto Expuesto Host | Propósito en la Integración |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Plataforma IoT** | ThingsBoard | `thingsboard/tb-postgres:latest` | `9090` (Web UI)<br>`1883` (MQTT) | `8080`<br>`1883` | Servidor central de visualización y broker de mensajería. |
| **Conector IoT** | ThingsBoard Gateway | `thingsboard/tb-gateway:latest` | N/A | N/A | Cliente Modbus TCP que interroga al simulador de tu compañero. |
| **Base de Datos** | PostgreSQL | Integrada en imagen TB | `5432` | No expuesto | Persistencia de datos históricos e información de dispositivos. |
| **Orquestador** | Docker Compose | Especificación `3.8` | N/A | N/A | Despliegue de red y ciclo de vida de los servicios de forma portable. |
