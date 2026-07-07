# RíoControl IA

**Prototipo web para el seguimiento inteligente de proyectos, ejecución presupuestaria, alertas preventivas, visualización territorial y análisis municipal asistido por inteligencia artificial.**

> Proyecto desarrollado para el Hackathon Innovasoft 2026.  
> Estado actual: prototipo funcional para revisión técnica, demostración.

---

## Descripción general

RíoControl IA es una plataforma web orientada al seguimiento de proyectos municipales relacionados con POA, PAC, presupuesto, procesos de contratación, pagos y avance físico.

La solución centraliza información operativa que normalmente puede estar dispersa en hojas de cálculo, informes o sistemas independientes, y la transforma en indicadores, alertas preventivas, ubicación territorial y análisis asistido por inteligencia artificial.

La plataforma permite responder de manera rápida a preguntas como:

- ¿Qué proyectos tienen pagos vencidos?
- ¿Qué Dirección presenta menor ejecución presupuestaria?
- ¿Cuál proyecto registra mayor atraso?
- ¿Cuánto presupuesto está comprometido, devengado o pagado?
- ¿Dónde se encuentra cada obra o intervención?
- ¿Qué procesos requieren atención prioritaria?

---

## Objetivo

Transformar datos dispersos de proyectos, presupuesto, pagos y territorio en información clara que facilite el seguimiento institucional y la toma oportuna de decisiones.

> RíoControl IA busca que un atraso sea identificado antes de convertirse en un problema crítico para la ejecución municipal.

---

## Módulos implementados

### 1. Autenticación y control de acceso

La plataforma utiliza Firebase Authentication para controlar el acceso institucional mediante correo electrónico y contraseña.

Se consideran tres perfiles principales:

| Rol | Alcance |
|---|---|
| Alcaldía | Visualización estratégica global, indicadores consolidados y reportes ejecutivos. |
| Dirección Financiera | Seguimiento global de ejecución presupuestaria, pagos, alertas e importación financiera. |
| Director/a de Gestión | Registro y seguimiento de los proyectos asignados a su Dirección. |

Cada usuario visualiza únicamente la información correspondiente a su alcance institucional.

---

### 2. Panel de control

El panel presenta indicadores consolidados para facilitar el seguimiento de la ejecución municipal:

- Ejecución global.
- Total comprometido.
- Total pagado.
- Número y monto de pagos vencidos.
- Ejecución por Dirección de Gestión.
- Distribución de proyectos por etapa contractual.
- Alertas prioritarias de atención.

---

### 3. Gestión de proyectos

Cada proyecto puede registrar la siguiente información:

- Nombre del proyecto.
- Código del proceso.
- Dirección responsable.
- Meta del POA.
- Ítem PAC.
- Etapa contractual.
- Fechas de inicio y finalización.
- Forma de pago.
- Presupuesto asignado.
- Certificado.
- Comprometido.
- Devengado.
- Pagado.
- Avance físico.
- Partidas presupuestarias.
- Hitos y pagos planificados.
- Ubicación territorial.

La aplicación valida la secuencia presupuestaria:

```text
Presupuesto asignado ≥ Certificado ≥ Comprometido ≥ Devengado ≥ Pagado
```

Esto ayuda a prevenir inconsistencias en la información financiera registrada.

---

### 4. Alertas preventivas

RíoControl IA identifica pagos pendientes cuya fecha prevista ya venció.

Las alertas permiten revisar:

- Proyecto relacionado.
- Dirección responsable.
- Monto en riesgo.
- Número de días de atraso.
- Hito pendiente.
- Nivel de riesgo.

Esto permite priorizar acciones antes de que los retrasos afecten la ejecución de un proyecto.

---

### 5. Mapa territorial

La plataforma permite ubicar proyectos en el territorio mediante diferentes tipos de geometría:

| Tipo | Uso recomendado |
|---|---|
| Punto | Parques, edificios, equipamientos u obras localizadas. |
| Línea | Vías, calles, rehabilitación vial, redes o corredores. |
| Área | Barrios, parques, zonas de intervención o proyectos territoriales amplios. |

Al seleccionar un proyecto en el mapa se puede consultar información como presupuesto, avance físico, etapa contractual, riesgo y pagos pendientes.

---

### 6. Importación financiera

El módulo de importación financiera permite cargar información estructurada desde archivos Excel o CSV.

La estructura esperada contempla campos como:

```text
codigoProceso
certificado
comprometido
devengado
pagado
fechaCorte
```

Este módulo facilita una futura integración con reportes financieros institucionales, reduciendo la necesidad de registrar manualmente grandes volúmenes de información.

---

### 7. MuniIA

MuniIA es el asistente inteligente institucional de RíoControl IA.

Permite:

- Generar borradores de proyectos a partir de texto.
- Analizar propuestas en formato PDF.
- Extraer datos como nombre, presupuesto, fechas, forma de pago, partidas e hitos.
- Completar un formulario editable antes de guardar.
- Responder consultas utilizando únicamente los proyectos visibles según el rol autenticado.

Ejemplos de consultas:

```text
¿Qué proyectos tienen pagos vencidos?
¿Cuál proyecto presenta mayor atraso?
¿Cuánto se ha devengado en Obras Públicas?
¿Qué proyectos se encuentran en ejecución?
```

MuniIA no sustituye al funcionario responsable. La inteligencia artificial genera un borrador, pero el usuario debe revisar y validar la información antes de guardarla.

---

## Arquitectura de la solución

```text
Usuario institucional
        ↓
Flutter Web - RíoControl IA
        ↓
Firebase Authentication
        ↓
Cloud Firestore
        ↓
Proyectos, pagos, alertas, indicadores y perfiles
        ↓
Firebase AI Logic / Gemini
        ↓
MuniIA: análisis documental y consultas institucionales
```

La aplicación está organizada por módulos funcionales para facilitar su mantenimiento y escalabilidad:

```text
lib/
├── app/
├── core/
│   ├── controladores/
│   ├── datos/
│   ├── modelos/
│   ├── servicios/
│   ├── tema/
│   ├── utilidades/
│   └── widgets/
├── features/
│   ├── alertas/
│   ├── autenticacion/
│   ├── importacion_financiera/
│   ├── mapa_territorial/
│   ├── panel_control/
│   ├── proyectos/
│   ├── registro_inteligente/
│   └── reportes_ia/
└── main.dart
```

---

## Tecnologías utilizadas

| Tecnología | Uso en la solución |
|---|---|
| Flutter Web | Desarrollo de la interfaz web responsiva. |
| Dart | Lenguaje principal de desarrollo. |
| Firebase Authentication | Inicio de sesión y control de acceso por usuarios. |
| Cloud Firestore | Almacenamiento de proyectos, perfiles, pagos y datos operativos. |
| Firebase AI Logic | Integración de MuniIA con modelos Gemini. |
| Gemini | Extracción de información desde texto o PDF y consultas institucionales. |
| flutter_map / OpenStreetMap | Visualización territorial de proyectos. |
| file_picker | Selección de archivos PDF, Excel y CSV. |
| GitHub | Control de versiones y revisión técnica del código. |

---

## Datos demostrativos

La versión actual utiliza datos demostrativos coherentes con escenarios de gestión municipal.

Estos datos permiten validar:

- Indicadores de ejecución.
- Cadena presupuestaria.
- Pagos vencidos.
- Alertas preventivas.
- Ubicación territorial.
- Roles de usuario.
- Registro manual de proyectos.
- Registro asistido por MuniIA.

> Los datos incluidos no deben considerarse información oficial del Municipio. Antes de una implementación institucional se requerirá validación e integración con fuentes oficiales autorizadas.

---

## Requisitos para ejecutar el proyecto

- Flutter SDK instalado.
- Google Chrome para ejecutar la versión web.
- Proyecto Firebase configurado.
- Firebase Authentication habilitado.
- Cloud Firestore habilitado.
- Firebase AI Logic configurado para MuniIA.
- Acceso a Internet para servicios Firebase, Gemini y mapas.

---

## Instalación y ejecución

Clonar el repositorio:

```bash
git clone https://github.com/riocontrol-ia/riocontrol-ia.git
```

Ingresar a la carpeta del proyecto:

```bash
cd riocontrol-ia
```

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar en Google Chrome:

```bash
flutter run -d chrome
```

Revisar errores de análisis:

```bash
flutter analyze
```

---

## Seguridad y consideraciones institucionales

Antes de una implementación en producción deben aplicarse medidas adicionales:

- Configurar reglas estrictas de Cloud Firestore.
- Activar Firebase App Check.
- Sustituir los datos demostrativos por datos institucionales autorizados.
- Definir responsables de administración de Firebase y Google Cloud.
- Implementar respaldo, auditoría y trazabilidad de cambios.
- Establecer controles de acceso para cada perfil institucional.
- No subir contraseñas, tokens, claves privadas o cuentas de servicio al repositorio.
- Mantener el repositorio privado mientras no exista autorización institucional para su publicación.

---

## Estado de implementación

| Componente | Estado |
|---|---|
| Inicio de sesión con Firebase | Implementado |
| Roles institucionales | Implementado |
| Panel de control | Implementado |
| Gestión de proyectos | Implementado |
| Cadena presupuestaria | Implementado |
| Alertas preventivas | Implementado |
| Mapa territorial | Implementado |
| Importación financiera | Implementado para prototipo |
| Registro manual de proyectos | Implementado |
| Registro desde texto o PDF con MuniIA | Implementado |
| Consultas institucionales con MuniIA | Implementado |
| Reporte ejecutivo asistido por IA | Implementado como prototipo |
| Integración con fuentes oficiales municipales | Pendiente de validación institucional |
| App Check y endurecimiento productivo | Pendiente |

---
