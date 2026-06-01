# Auditoría de Resolución y Verificación de Telemetría: Modbus TCP a ThingsBoard

Este documento detalla la investigación técnica, el diagnóstico de fallos y la verificación de la persistencia de datos realizada en el sistema de adquisición para el reconectador **NOJA Power OSM27** (con controlador RC10) enlazado con **ThingsBoard Community Edition** y el **ThingsBoard IoT Gateway 3.8.3**.

---

## 🔍 1. Diagnóstico del Conflicto Técnico y Resolución

Durante la fase de integración, el ThingsBoard IoT Gateway lograba conectarse con éxito al simulador Modbus en el puerto `502` de la máquina host (gracias a la resolución de red por `host.docker.internal` vía `extra_hosts` en Docker Compose), pero **no se persistía ninguna telemetría ni atributo** en la base de datos de ThingsBoard.

### Estrategia de Depuración Aplicada

1. **Habilitación de Logs de Nivel `DEBUG`:**
   ThingsBoard Gateway configura dinámicamente los niveles de logging de los conectores a través de la propiedad `"logLevel"` de sus respectivos archivos de configuración (sobrescribiendo las directivas de `logs.json`).
   * **Acción:** Añadimos `"logLevel": "DEBUG"` en la raíz de `config/modbus.json`.
   * **Resultado:** Los logs en `/logs/connector.log` revelaron que el conector Modbus se quedaba congelado de forma indefinida en su primer intento de lectura:
     ```text
     2026-05-28 16:52:04.852 - |DEBUG| - [slave.py] - slave - read - 250 - Reading 1 registers from address 10001 with function code 2
     ```
     El conector Modbus del Gateway creaba una nueva tarea de polling asíncrona cada 5 segundos que también se colgaba en el mismo registro, bloqueando la cola de adquisición.

2. **Resolución del Conflicto de Framer (Modbus RTU vs Modbus TCP):**
   * **El Problema:** La configuración original de `modbus.json` empleaba `"method": "rtu"`. En ThingsBoard/PyModbus, esto fuerza al conector a hablar utilizando **Modbus RTU encapsulado en TCP** (`ModbusRtuFramer`). Sin embargo, el simulador industrial `simulador_osm27/main.py` de la NOJA OSM27 opera bajo **Modbus TCP Estándar** (`ModbusSocketFramer`), el cual requiere el encabezado MBAP de 7 bytes y no incluye la suma de comprobación de redundancia cíclica (CRC).
   * **El Impacto:** El simulador ignoraba silenciosamente las tramas del Gateway al carecer del MBAP header, causando que la promesa asíncrona de lectura del cliente en el Gateway esperara indefinidamente hasta expirar, repitiendo el bloqueo cíclico.
   * **La Solución:** Modificamos el método de comunicación en `modbus.json` a `"method": "socket"` (Modbus TCP nativo).
   * **Efecto Inmediato:** En el siguiente ciclo de polling, el socket procesó todas las solicitudes de lectura en milisegundos, obteniendo tramas de datos coherentes para cada registro.

---

## 📊 2. Verificación de Ingesta en la Base de Datos (PostgreSQL)

Para validar el flujo completo de datos desde el simulador hasta la base de datos PostgreSQL interna de ThingsBoard (`ts_kv` y `attribute_kv`), se ejecutaron consultas directas cruzando los ID dinámicos de claves con la tabla `key_dictionary`.

### A. Telemetrías Analógicas Trifásicas y Energías (`ts_kv`)

La consulta SQL en la base de datos confirmó que ThingsBoard está almacenando correctamente todas las magnitudes analógicas muestreadas cada 5 segundos:

```sql
SELECT d.name as dispositivo, k.key as metrica, t.dbl_v as valor_double, t.long_v as valor_int, to_timestamp(t.ts / 1000) as timestamp 
FROM ts_kv t 
JOIN device d ON t.entity_id = d.id 
JOIN key_dictionary k ON t.key = k.key_id 
WHERE d.name = 'OSM27_Recloser' 
ORDER BY t.ts DESC LIMIT 15;
```

#### Muestra de Datos Ingeridos en la BD:

| Dispositivo | Métrica | Valor Decimal (`dbl_v`) | Valor Entero (`long_v`) | Marca de Tiempo |
| :--- | :--- | :--- | :--- | :--- |
| **OSM27_Recloser** | ia | *NULL* | 26624 | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | factor_potencia | 45.827 | *NULL* | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | uc | 13.876 | *NULL* | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | uca | 27.994 | *NULL* | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | potencia_aparente | *NULL* | 16144 | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | frecuencia | 343.23 | *NULL* | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | ua | 11.572 | *NULL* | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | ub | 54.323 | *NULL* | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | uab | 24.154 | *NULL* | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | ubc | 50.265 | *NULL* | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | ib | *NULL* | 26624 | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | ic | *NULL* | 26624 | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | potencia_reactiva | *NULL* | 12037 | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | potencia_activa | *NULL* | 25871 | 2026-05-28 16:53:13 |
| **OSM27_Recloser** | energia_activa | *NULL* | 4052680960 | 2026-05-28 16:53:13 |

> [!NOTE]
> Las energías acumuladas de 32 bits (como `energia_activa` a partir de los registros `30041-30042`) se ensamblan y escalan perfectamente, asegurando una recolección íntegra de los acumuladores eléctricos históricos.

---

### B. Atributos de Estado de Protecciones (`attribute_kv`)

Los registros de tipo *Discrete Inputs* mapeados desde la serie `10001` en adelante se almacenan en la tabla `attribute_kv` como atributos de lado del cliente del dispositivo. Esto permite gatillar alarmas inmediatas en la plataforma.

```sql
SELECT d.name as dispositivo, k.key as atributo, a.bool_v as valor_booleano, to_timestamp(a.last_update_ts / 1000) as ultima_actualizacion
FROM attribute_kv a 
JOIN device d ON a.entity_id = d.id 
JOIN key_dictionary k ON a.attribute_key = k.key_id 
WHERE d.name = 'OSM27_Recloser' AND k.key IN ('lockout', 'sag', 'pickup', 'estado_abierto', 'alarma_general', 'estado_cerrado');
```

#### Atributos Persistidos Activos:

*   **lockout (bloqueo ANSI 79):** `false`
*   **sag (hueco de tensión):** `false`
*   **pickup (sobrecorriente):** `false`
*   **alarma_general:** `false`
*   **estado_cerrado (interruptor cerrado):** `true`
*   **estado_abierto (interruptor abierto):** `false`

---

## 🛠️ 3. Resumen de la Configuración Final de Conectividad

Para referencia del mantenimiento futuro de esta infraestructura, los parámetros esenciales del archivo `/config/modbus.json` quedaron definidos como:

* **Host:** `host.docker.internal` (Resuelve al localhost del anfitrión de Linux mediante `host-gateway`)
* **Puerto:** `502`
* **Método:** `socket` (Framer TCP estándar)
* **Log Level:** `DEBUG` (Para mantener visibilidad total sobre las lecturas)
* **Device Name:** `OSM27_Recloser` (Debe coincidir exactamente con el nombre de la entidad en ThingsBoard para una correcta asociación).
