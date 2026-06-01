Como Ingeniero de Calidad de Software, y basándome en los lineamientos del SWEBOK para el seguimiento y traza de requisitos, he elaborado la Matriz de Trazabilidad de Requerimientos. Esta herramienta es fundamental para asegurar que cada especificación solicitada en la Consigna tenga su correlato técnico en el Manual Modbus del equipo NOJA Power y cuente con un método de verificación claro para las etapas de prueba.

A continuación se presenta la matriz estructurada, garantizando la granularidad exigida para las variables eléctricas del Requerimiento Funcional 1 (RF1).

### **Matriz de Trazabilidad de Requerimientos**

| ID Req. | Descripción de la Tarea Técnica | Fuente Exacta (Manual / Consigna) | Método de Verificación (Prueba sugerida) |
| ----- | ----- | ----- | ----- |
| **RF1.1** | Leer Tensiones de Fase (Ua, Ub, Uc). | Input Registers Modbus: `30005`, `30006`, `30007`. | Inspección de tramas de red Modbus (ej. Wireshark) y verificación de log del cliente. |
| **RF1.2** | Leer Tensiones de Línea (Uab, Ubc, Uca). | Input Registers Modbus: `30011`, `30012`, `30013`. | Inspección de tramas de red Modbus y validación de escalado. |
| **RF1.3** | Leer Corrientes por fase (Ia, Ib, Ic). | Input Registers Modbus: `30001`, `30002`, `30003`. | Inspección de tramas Modbus, comparando valor leído con la inyección del simulador. |
| **RF1.4** | Leer Potencia Activa Total (kW). | Input Register Modbus: `30028`. | Inspección de tramas Modbus. |
| **RF1.5** | Leer Potencia Reactiva Total (kVAr). | Input Register Modbus: `30027`. | Inspección de tramas Modbus. |
| **RF1.6** | Leer Potencia Aparente Total (kVA). | Input Register Modbus: `30026`. | Inspección de tramas Modbus. |
| **RF1.7** | Leer Factor de Potencia (Trifásico). | Input Register Modbus: `30068` (Requiere multiplicador x0.001). | Prueba de límite y formato: inyectar 0x7FFF y verificar manejo de error. |
| **RF1.8** | Leer Frecuencia de red (Hz). | Input Register Modbus: `30061` (Fabc) o `30062` (Frst). | Inspección de tramas y verificación del multiplicador (x0.01 o x0.001 según manual). |
| **RF1.9** | Obtener Energía Activa Acumulada (kWh). | *Brecha documentada:* Cálculo por software integrando la potencia activa (Reg `30028`) en el tiempo. | Revisión de código (cálculo iterativo) e inspección de acumulador en la Base de Datos. |
| **RF1.10** | Leer Energía Reactiva Acum. (kVArh). | Input Registers Modbus: `30043` (\_Hi), `30044` (\_Lo). | Prueba de ensamblado Big-Endian de 32-bits en el backend. |
| **RF1.11** | Monitorear Estado Abierto/Cerrado. | Discrete Inputs Modbus: `10035` (Open All), `10075` (Closed All). | Prueba funcional dinámica: inyectar comando de cambio y validar estados 0 y 1\. |
| **RF1.12** | Monitorear Estado Bloqueado (Lockout). | Discrete Input Modbus: `10001`. | Prueba de inyección de falla de bloqueo y verificación del bit lógico. |
| **RF1.13** | Leer Contadores de Operaciones. | Input Register Modbus: `30072` (CO Total). | Inspección de tramas Modbus tras simulaciones de apertura/cierre. |
| **RF1.14** | Obtener Registros de Eventos y Alarmas. | Discrete Inputs Modbus: `10010` (Pickup), `10036` (Open Prot), `10064` (Alarma), `10118` (Warning). | Prueba de polling rápido; verificación de registro de flancos positivos en el sistema. |
| **RF2.1** | Exponer Servidor Modbus-TCP (Simulador). | Consigna RF2; Manual NOJA (SGA TCP\_PORT `502`). | Escaneo de puertos (nmap al puerto 502\) y conexión exitosa con cliente genérico Modbus. |
| **RF2.2** | Generar variaciones temporales de variables. | Consigna RF2 (Simulación realista). | Prueba de caja negra: Observar las curvas en el tiempo en un cliente sin inyectar fallas. |
| **RF2.3** | Inyección manual de fallas en simulador. | Consigna RF2 (Testing de escenarios). | Prueba de inyección manual de sobrecorriente o baja tensión y validación de respuesta. |
| **RF3.1** | Adquisición de datos mediante Polling. | Consigna RF3. | Análisis de tráfico de red y medición de latencia en la solicitud/respuesta Modbus. |
| **RF3.2** | Almacenamiento histórico de datos. | Consigna RF3 (Estrategia de retención). | Inspección de tablas en la Base de Datos; validación de operaciones `INSERT` promediadas. |
| **RF4.1** | Dashboard visual: Tiempo Real (V, I, P, FP, Hz). | Consigna RF4. | Prueba de UI: Comparar valores mostrados en los widgets web vs. valores del simulador. |
| **RF4.2** | Dashboard visual: Gráficos históricos. | Consigna RF4 (Rango temporal). | Prueba de integración de UI con API del backend; aplicar filtros de fechas y observar renderizado. |
| **RF4.3** | Dashboard visual: Estado y Alarmas. | Consigna RF4 (Eventos y Calidad de Energía). | Prueba funcional: Disparar evento en simulador y verificar aparición en la tabla de alarmas web. |
| **RF5.1** | Detección de condiciones anómalas lógicas. | Consigna RF5 (Sobrecorriente, Bloqueo, Pérdida de comunicación). | Pruebas Unitarias automatizadas sobre el motor de reglas de alerta del backend. |
| **RF5.2** | Notificación mediante alertas visuales. | Consigna RF5 (Dashboard visual). | Inspección de la UI: Inyectar falla y comprobar cambio de color o pop-up en el frontend. |
| **RF5.3** | Notificación externa (Email, Telegram/WA). | Consigna RF5 (Canales de notificación). | Prueba de integración E2E: Generar falla en simulador y constatar recepción efectiva de Email/Mensaje. |

