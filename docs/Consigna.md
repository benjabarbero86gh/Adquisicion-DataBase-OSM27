# Aplicaciones TCP/IP 2026

## Parcial Práctico Integrador

## Tema 2

**Objetivo:**
Desarrollar una solución tecnológica al problema planteado aplicando lo aprendido durante
el cursado de la materia y siguiendo el proceso estudiado de la ingeniería del software.
**Deadline:** 17/06/
**Enunciado:**
El Instituto de Protecciones de Sistemas Eléctricos de Potencia (IPSEP), dependiente de la
Facultad de Ingeniería de la Universidad Nacional de Río Cuarto, los ha contratado para
desarrollar un sistema de monitoreo para el reconectador automático OSM27 de NOJA
Power, instalado en el campus de la UNRC.
El IPSEP considera que este desarrollo permitirá una mejora sustancial en la operación del
equipamiento, posibilitando el monitoreo continuo de sus variables eléctricas, la recopilación
de datos históricos para la toma de decisiones y el control de la calidad de la energía
suministrada al campus.
A continuación se describen los requerimientos funcionales que deberá contemplar la
solución.
**RF1 — Relevamiento del protocolo de comunicación**
El OSM27 expone sus datos a través del protocolo Modbus-TCP. El grupo deberá relevar la
documentación técnica oficial del equipo (manuales, hojas de datos y recursos disponibles
en el sitio de NOJA Power) e identificar el mapa de registros Modbus disponibles. Se deberá
documentar, como mínimo, los registros asociados a los siguientes parámetros de interés:
● Tensiones de fase y de línea (V)
● Corrientes por fase (A)
● Potencia activa, reactiva y aparente (W, VAR, VA)
● Factor de potencia
● Frecuencia de red (Hz)
● Energía activa y reactiva acumulada (kWh, kVARh)
● Estado del reconectador (abierto / cerrado / bloqueado)
● Contadores de operaciones de reconexión
● Registros de eventos y alarmas
Este relevamiento debe quedar documentado en el informe de requerimientos y ser la base
del diseño del sistema.
**RF2 — Simulador del reconectador OSM**
Dado que no se dispone de acceso al hardware real durante el desarrollo, el grupo deberá


implementar un simulador del reconectador OSM27 que emule el comportamiento del
dispositivo mediante el protocolo Modbus-TCP. El simulador deberá:
● Exponer un servidor Modbus-TCP con los registros relevados en RF1.
● Generar valores simulados con variación temporal realista para los parámetros
eléctricos (incluyendo variaciones de tensión, sobrecorrientes y eventos de
reconexión).
● Permitir inyectar manualmente condiciones de falla o eventos para validar el
comportamiento del sistema de monitoreo y las alertas.
El simulador es un entregable independiente y debe poder ejecutarse de forma autónoma
para facilitar las pruebas del sistema.
**RF3 — Sistema de adquisición y almacenamiento de datos**
El sistema deberá conectarse al reconectador (o al simulador) mediante Modbus-TCP,
adquirir los registros de forma periódica y almacenarlos para su análisis posterior. El grupo
deberá decidir el stack tecnológico (protocolo de adquisición, motor de base de datos,
frecuencia de muestreo, estrategia de retención de datos) y justificar dicha decisión en el
documento de diseño mediante un análisis de trade-off entre las alternativas evaluadas.
Esta decisión es parte de la evaluación.
**RF4 — Dashboard de monitoreo**
El sistema deberá contar con una interfaz web de monitoreo tipo dashboard que permita
visualizar en tiempo real e históricamente los parámetros relevados. Como mínimo, el
dashboard deberá incluir:
● Visualización en tiempo real de tensiones, corrientes, potencias y factor de potencia.
● Gráficos históricos con selección de rango temporal para todos los parámetros de
interés.
● Indicadores de estado del reconectador (abierto / cerrado / bloqueado) y contador de
operaciones.
● Panel de eventos y alarmas registradas.
● Indicadores de calidad de energía (variaciones de tensión, desbalance de fases,
distorsión armónica si el equipo lo expone).
**RF5 — Sistema de alertas y notificaciones**
El sistema deberá detectar condiciones anómalas y notificar al personal responsable. Las
condiciones a monitorear incluyen, como mínimo: operación de reconexión, tensión fuera de
rango, sobrecorriente, pérdida de comunicación con el equipo y bloqueo del reconectador.
Las notificaciones deberán contemplar los siguientes canales:
● Alerta visual en el dashboard (indicador de estado y registro de eventos).
● Envío de correo electrónico al personal responsable.
Notificación por mensajería instantánea (Telegram o WhatsApp), evaluando la viabilidad de
cada canal e implementando al menos uno. La elección y justificación deben quedar
documentadas en el diseño.


Figura: Proyecto de Sistema de monitoreo para reconectador automático
**Consigna** :
Llevar adelante el desarrollo completo del sistema en el marco del proceso de ingeniería del
software según el SWEBOK de la IEEE (Versión 3.0). Se deberá entregar documentación
completa (requerimientos, diseño, implementación y pruebas) y presentar un demostrador
tecnológico de la solución que integre el simulador del OSM27 con el sistema de monitoreo
completo. La elección del stack tecnológico forma parte de las decisiones de diseño que el
grupo deberá justificar.
**Grupo** :

## Integrantes Actividad

```
BARBERO CORTEZ, Benjamin (Team Leader)
GONSALEZ CONTRERAS, Pablo
MOYANO, Aldair
RODRIGUEZ ABALLAY, Carlos
Documentación:
```
- Requerimientos
- Diseño
- Implementación
- Pruebas
Demostrador Tecnológico


