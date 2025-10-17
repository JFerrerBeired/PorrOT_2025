### Hoja de Ruta de Implementación por Hitos**

**Propósito:** Este documento describe una secuencia de hitos de desarrollo incremental para la construcción de la aplicación. Cada hito representa una entrega de valor funcional y verificable. Sirve como una guía de alto nivel para el desarrollador, quien deberá consultar los documentos de Especificación Funcional, Arquitectura Técnica y UI/UX para los detalles de implementación.

También es responsabilidad del desarrollador actualizar este documento conforme vaya avanzando en él.

---

#### **Hito 1: El Andamiaje y los Datos Maestros**

*   **Estado:** `[x] Completo`

*   **Objetivo:** Establecer la base técnica del proyecto, configurar la infraestructura de datos y crear una vía para introducir los datos maestros (concursantes y galas) que son prerrequisito para cualquier otra funcionalidad.

*   **Desarrollos Clave:**
    *   [x] Configurar el proyecto en Firebase y la conexión con la app Flutter.
    *   [x] Crear la estructura de directorios del proyecto siguiendo la Clean Architecture (`data`, `domain`, `presentation`).
    *   [x] Definir todas las Entidades y Modelos de Datos (User, Gala, Contestant, Prediction, AppConfig).
    *   [x] Implementar una vista básica de Panel de Administración (puede ser una ruta de acceso directo) que permita:
        *   Crear y editar documentos en la colección `contestants` (incluyendo la gestión de sus estados: activo, nominado, eliminado, ganador).
        *   Crear documentos básicos en la colección `galas` (solo con `galaId` y `galaNumber`).

*   **Criterio de Aceptación (Stop & Test):** Al finalizar, debe ser posible ejecutar la app, acceder al panel de administración y crear concursantes y galas. La correcta creación de estos documentos debe ser verificable directamente en la consola de Cloud Firestore.

---

#### **Hito 2: El Flujo de Predicción del Jugador (End-to-End)**

*   **Estado:** `[x] Incompleto`

*   **Objetivo:** Implementar la funcionalidad central desde la perspectiva del jugador: el ciclo completo de identificación, acceso y envío de una predicción para una gala.

*   **Desarrollos Clave:**
    *   [x] Implementar la `PlayerSelectionScreen` con la lógica para seleccionar un usuario existente o crear uno nuevo.
    *   [x] Implementar una `DashboardScreen` básica que muestre un saludo y el botón para navegar a la pantalla de predicción.
    *   [x] Implementar la `PredictionScreen` con todo su formulario, incluyendo la lógica de UI para la selección de salvados.
    *   [x] Implementar el Caso de Uso y el Repositorio para guardar un documento de predicción en la colección `predictions` de Firestore.

*   **Criterio de Aceptación (Stop & Test):** Un usuario debe poder iniciar la app, elegir/crear su perfil, rellenar completamente el formulario de predicción y guardarlo. La creación de un documento en `predictions` con los datos correctos debe ser verificable en Firestore.

---

#### **Hito 3: El Cerebro: Cálculo de Puntuaciones**

*   **Estado:** `[ ] Incompleto`

*   **Objetivo:** Desarrollar la lógica de negocio crítica que convierte las predicciones y resultados en puntos, dando sentido al juego.

*   **Desarrollos Clave:**
    *   [ ] Implementar la clase de servicio `ScoreCalculator` con las reglas de puntuación definidas.
    *   [ ] Ampliar el Panel de Administración para permitir al administrador introducir los resultados oficiales en el mapa `results` de un documento de `gala`.
    *   [ ] Añadir un botón "Calcular Puntuaciones" al panel que, para una gala seleccionada, itere sobre todas sus predicciones, calcule los puntos y actualice los documentos correspondientes en Firestore (`predictions` y `users`). Por ejemplo puede hacerse desde la vista de galas con un botón que recalcule las puntuaciones y active el servicio.
    *   [x] Añadir funcionalidad al panel de administración para actualizar los estados de los concursantes según los resultados de las galas.

*   **Criterio de Aceptación (Stop & Test):** Con predicciones de prueba creadas en el Hito 2, el administrador debe poder rellenar los resultados de una gala y ejecutar el cálculo. Se debe verificar en Firestore que los campos `score` y `totalScore` se han rellenado con los valores correctos.

---

#### **Hito 4: La Recompensa: Visualización de Resultados**

*   **Estado:** `[ ] Incompleto`

*   **Objetivo:** Cerrar el ciclo de la experiencia de usuario mostrando los resultados, la clasificación y el histórico, lo que constituye la principal motivación para jugar.

*   **Desarrollos Clave:**
    *   [ ] Implementar el widget de Ranking General en la `DashboardScreen`, obteniendo y mostrando los datos de la colección `users`.
    *   [ ] Implementar la `HistoryScreen` completa, mostrando la matriz de Jugadores vs. Galas con sus respectivas puntuaciones.
    *   [ ] Desarrollar los Casos de Uso y Repositorios necesarios para obtener los datos de puntuaciones de forma eficiente.

*   **Criterio de Aceptación (Stop & Test):** Después de ejecutar el cálculo del Hito 3, un usuario debe poder iniciar la sesión y ver la clasificación correcta en el dashboard y la tabla de histórico completamente rellenada. La aplicación debe sentirse funcionalmente completa.

---

#### **Hito 5: Puesta a Punto y Gestión de Estado**

*   **Estado:** `[ ] Incompleto`

*   **Objetivo:** Añadir las funcionalidades de gestión de estado de la aplicación, pulir la experiencia de usuario y preparar el proyecto para su despliegue final.

*   **Desarrollos Clave:**
    *   [ ] Implementar la lógica para leer la `activeGalaId` desde `app_config/settings`.
    *   [ ] Conectar el botón "¡Haz tu predicción!" del Dashboard para que utilice la `activeGalaId`.
    *   [ ] Ampliar el Panel de Administración para permitir al administrador seleccionar y guardar la `activeGalaId`.
    *   [ ] Añadir indicadores de carga (`CircularProgressIndicator`) en las pantallas mientras se obtienen los datos de Firestore.
    *   [ ] Realizar las configuraciones necesarias para la compilación y despliegue (build) en las plataformas objetivo (web, Android).

*   **Criterio de Aceptación (Stop & Test):** El administrador puede controlar de forma remota qué gala está disponible para predecir. La interfaz de usuario se siente fluida y gestiona los estados de espera. La aplicación está compilada y lista para ser compartida con los amigos.