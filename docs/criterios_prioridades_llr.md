# Criterios de Asignación de Prioridades para Requerimientos de Bajo Nivel (LLR)

Este documento justifica la asignación de prioridades (escala 1 al 5, donde 1 es la máxima criticidad) para los Requerimientos de Bajo Nivel (LLR) del sistema de adquisición y monitoreo del reconectador OSM27.

## Criterio General de Asignación

Se ha adoptado el siguiente criterio basado en la criticidad para la operación del sistema mínimo viable y el cumplimiento de la consigna principal (RF1 a RF5 establecidos como Prioridad 1):

*   **Prioridad 1 (Crítico - Núcleo del Sistema):** Funcionalidades indispensables. Sin ellas, el sistema no puede establecer comunicación, no hay simulación base o no hay visualización mínima.
*   **Prioridad 2 (Alta - Valor Operativo Significativo):** Funcionalidades requeridas que aportan la utilidad histórica y analítica al sistema, además de los mecanismos primarios de alerta.
*   **Prioridad 3 (Media - Funcionalidad Extendida):** Funcionalidades que mejoran la experiencia de prueba (inyecciones manuales) o canales secundarios de notificación. (Se asume que la consigna exige implementar "al menos uno" de los canales externos, por lo que uno es prioridad más alta que el otro).

---

## Asignación Detallada de Prioridades LLR

### Relacionados a Adquisición de Datos (DAQ / COM)
*   **[Prioridad 1] LLR_DAQ_001:** Lectura Modbus de mediciones básicas (Tensiones, Corrientes, Frecuencia, FP). Es el corazón de la adquisición en tiempo real.
*   **[Prioridad 1] LLR_DAQ_003:** Polling Modbus de estados discretos (Abierto, Cerrado, Bloqueo). Fundamental para conocer el estado físico del equipo de maniobra.
*   **[Prioridad 2] LLR_DAQ_002:** Ensamblado y lectura Modbus de registros de 32 bits (Energía Acumulada). Requiere procesamiento adicional (fusión de words) y, aunque importante, es estadístico en comparación con los valores instantáneos.

### Relacionados al Simulador (SIM)
*   **[Prioridad 1] LLR_SIM_001:** Exponer servidor Modbus-TCP en puerto 502. Sin esto, no hay equipo al cual conectarse, bloqueando el resto del desarrollo.
*   **[Prioridad 2] LLR_SIM_002:** Generar variaciones temporales realistas. Es vital para probar el almacenamiento histórico y los gráficos de forma dinámica.
*   **[Prioridad 3] LLR_SIM_003:** Interfaz para inyectar fallas manualmente. Es una herramienta de prueba muy útil, pero el sistema operaría pasivamente sin ella.

### Relacionados a la Interfaz Web (GUI)
*   **[Prioridad 1] LLR_GUI_001:** Componentes en tiempo real (displays numéricos, luces de estado). El principal objetivo del dashboard web.
*   **[Prioridad 2] LLR_GUI_002:** Gráficos de series de tiempo históricos. Aporta el valor analítico principal a la plataforma ThingsBoard.
*   **[Prioridad 2] LLR_GUI_003:** Panel visual de eventos y alarmas registradas. Esencial para la trazabilidad operativa del personal.

### Relacionados a Alertas (ALR)
*   **[Prioridad 1] LLR_ALR_001:** Detección en el backend de condiciones de fallo e interrupción de la comunicación. La lógica base del sistema de seguridad.
*   **[Prioridad 2] LLR_ALR_002:** Generación de alertas visuales en el Dashboard. Es el mecanismo primario e inmediato de notificación.
*   **[Prioridad 2] LLR_ALR_003:** Envío de notificaciones por Correo Electrónico. Solución asíncrona estándar en la industria.
*   **[Prioridad 3] LLR_ALR_004:** Envío de notificaciones por Telegram / WhatsApp. La consigna indica evaluar viabilidad e implementar "al menos uno" de los externos (Email vs Telegram). Se le asigna prioridad 3 considerándolo un canal secundario (Nice-to-have) si el correo ya está operativo.
