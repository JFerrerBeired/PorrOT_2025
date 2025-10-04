### **Documento Técnico: Arquitectura Técnica y Modelo de Datos**

#### **1. Arquitectura de Software**

La aplicación se desarrollará siguiendo los principios de la **Clean Architecture**, asegurando una estricta separación de responsabilidades, alta capacidad de prueba y mantenibilidad a largo plazo. La estructura se dividirá en tres capas principales:

*   **1.1. Capa de `Presentation` (Frontend - Flutter):**
    *   **Responsabilidad:** Contiene todos los elementos relacionados con la UI/UX (Widgets, Vistas, Animaciones). Es responsable de mostrar los datos al usuario y de capturar sus interacciones.
    *   **Tecnologías:** Framework Flutter. Se utilizará un gestor de estado (ej. Riverpod o BLoC) para conectar la UI con la lógica de negocio.
    *   **Dependencias:** Depende exclusivamente de la capa `Domain`. No debe tener conocimiento directo de la capa `Data`.

*   **1.2. Capa de `Domain` (Lógica de Negocio):**
    *   **Responsabilidad:** Es el núcleo de la aplicación. Contiene la lógica de negocio pura, las reglas del juego y las entidades principales. No tiene dependencias externas (ni Flutter, ni Firebase).
    *   **Componentes Clave:**
        *   **Entidades (Entities):** Modelos de objeto puros (POCOs - Plain Old Dart Objects) que representan los conceptos centrales (Usuario, Gala, Predicción).
        *   **Casos de Uso (Use Cases):** Clases que encapsulan una única funcionalidad o acción de negocio (ej. `SubmitPredictionUseCase`, `GetRankingUseCase`).
        *   **Repositorios (Abstractos):** Interfaces que definen los contratos para la obtención y persistencia de datos (ej. `PredictionRepository`), de los cuales dependen los Casos de Uso.

*   **1.3. Capa de `Data` (Datos):**
    *   **Responsabilidad:** Implementa los contratos de repositorio definidos en la capa `Domain`. Se encarga de la comunicación con las fuentes de datos externas y de la serialización/deserialización de los datos.
    *   **Tecnologías:** Firebase (Firestore).
    *   **Componentes Clave:**
        *   **Modelos de Datos (Models):** Clases que extienden las Entidades del dominio y añaden la lógica para convertir datos de/hacia el formato de Firestore (`fromFirestore`, `toFirestore`).
        *   **Implementaciones de Repositorios:** Clases concretas (ej. `PredictionRepositoryImpl`) que implementan las interfaces del dominio realizando las llamadas a la API de Firestore.

#### **2. Modelo de Datos (Cloud Firestore)**

La persistencia de datos se gestionará a través de una base de datos NoSQL en Cloud Firestore. La estructura se organizará en las siguientes colecciones:

*   **2.1. `app_config`**
    *   Colección con un único documento: `settings`.
    *   **Propósito:** Almacenar la configuración global y el estado de la aplicación.
    *   **Campos del documento `settings`:**
        *   `activeGalaId` (string): El ID de la gala actualmente abierta para predicciones (ej. "gala_03").

*   **2.2. `users`**
    *   Cada documento representa a un jugador. El ID del documento es autogenerado por Firestore.
    *   **Propósito:** Almacenar la lista de participantes y su puntuación total.
    *   **Campos del documento:**
        *   `displayName` (string): Nombre único del jugador (ej. "Critias").
        *   `totalScore` (number): Puntuación total acumulada a lo largo del concurso.

*   **2.3. `contestants`**
    *   Cada documento representa a un concursante de OT.
    *   **Propósito:** Servir como base de datos maestra de los concursantes.
    *   **Campos del documento:**
        *   `contestantId` (string): Identificador único (ej. "concursante_01").
        *   `name` (string): Nombre completo del concursante.
        *   `photoUrl` (string): URL a una imagen del concursante.
        *   `status` (string): Estado actual ("activo", "nominado", "eliminado", "ganador").

*   **2.4. `galas`**
    *   Cada documento representa una gala semanal del concurso.
    *   **Propósito:** Almacenar la información y los resultados oficiales de cada gala.
    *   **Campos del documento:**
        *   `galaId` (string): Identificador único (ej. "gala_01").
        *   `galaNumber` (number): El número de la gala (1, 2, 3...).
        *   `date` (timestamp): Fecha de la gala.
        *   `nominatedContestants` (array of string): IDs de los dos concursantes nominados de la semana anterior, sobre los que se vota el eliminado.
        *   `results` (map): Objeto que almacena los resultados reales introducidos por el administrador.
            *   `favoriteId` (string)
            *   `eliminatedId` (string)
            *   `nomineeProposalIds` (array of string)
            *   `savedByProfessorsId` (string)
            *   `savedByPeersId` (string)

*   **2.5. `predictions`**
    *   Cada documento es la predicción de un único usuario para una única gala.
    *   **Propósito:** Almacenar todas las apuestas realizadas por los jugadores.
    *   **Campos del documento:**
        *   `userId` (string): ID del documento del usuario que realiza la predicción (referencia a `users`).
        *   `galaId` (string): ID del documento de la gala correspondiente (referencia a `galas`).
        *   `favoriteId` (string)
        *   `eliminatedId` (string)
        *   `nomineeProposalIds` (array of string)
        *   `savedByProfessorsId` (string)
        *   `savedByPeersId` (string)
        *   `score` (number): Puntuación obtenida en esta predicción específica, una vez calculada.
        *   `scoreBreakdown` (map): Objeto detallando la procedencia de los puntos (ej. `{ "favorite": 10, "nominee_base": 30, ... }`).

#### **3. Lógica de Negocio (El "Cerebro")**

*   **3.1. Sistema de Puntuación:**
    *   **Acierto Favorito:** 10 puntos.
    *   **Acierto Eliminado:** 10 puntos.
    *   **Aciertos en Propuestos a Nominado (sobre 4):**
        *   1 acierto: 5 puntos.
        *   2 aciertos: 15 puntos.
        *   3 aciertos: 30 puntos.
        *   4 aciertos: 50 puntos.
    *   **Bonus por Roles (puntos extra):**
        *   +5 puntos por acertar el "Salvado por Profesores" (debe ser uno de los 4 propuestos a nominado).
        *   +5 puntos por acertar el "Salvado por Compañeros" (debe ser uno de los 4 propuestos a nominado).
    *   **Nota sobre Nominados Finales:** Los dos concursantes propuestos a nominación que no son salvados por profesores o compañeros se convierten en los "Nominados Finales" para la gala siguiente. Acertarlos no otorga puntos adicionales, ya que forman parte de los "Propuestos a Nominado".

*   **3.2. Proceso de Cálculo de Puntuaciones:**
    1.  El proceso es iniciado manualmente por el Administrador desde su panel.
    2.  La lógica se ejecutará en la aplicación cliente del Administrador.
    3.  El algoritmo obtendrá de Firestore los resultados de la gala en cuestión y todas las predicciones asociadas a esa `galaId`.
    4.  Para cada predicción, se aplicarán las reglas del Sistema de Puntuación.
    5.  El `score` y `scoreBreakdown` resultantes se escribirán en el documento de `prediction` correspondiente.
    6.  Posteriormente, se recalculará el `totalScore` para cada usuario sumando los nuevos puntos y se actualizará el documento correspondiente en la colección `users`.