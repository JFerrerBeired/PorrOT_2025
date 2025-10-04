### **Documento Técnico: Especificación de Interfaz y Experiencia de Usuario (UI/UX)**

#### **1. Mapa de Navegación**

El flujo principal de la aplicación se estructura a través de las siguientes pantallas:

```
[PlayerSelectionScreen] --(Selecciona/Crea Usuario)--> [DashboardScreen]
       ^                                                     |
       |                                                     |
       +--(Cambiar Usuario)----------------------------------+
       |
       +-----> [PredictionScreen]  <--(Realizar Predicción)--+
       |
       +-----> [HistoryScreen]  <--(Ver Histórico)-----------+
       |
       +-----> [AdminPanelScreen]  <--(Acceso Admin)---------+ (Visible solo para Admin)
```
La navegación principal para el usuario estándar se gestionará mediante una `BottomNavigationBar` en el `DashboardScreen` que permitirá alternar entre "Dashboard" y "Histórico".

#### **2. Desglose de Vistas (Screens)**

**2.1. `PlayerSelectionScreen` (Pantalla de Selección de Jugador)**

*   **Propósito:** Permitir al usuario identificarse para la sesión de juego. Es la primera pantalla de la aplicación.
*   **Componentes Clave:**
    *   Título: "PorrOT 2025".
    *   `ListView` / `GridView`: Muestra una lista de los `displayName` de todos los usuarios existentes. Cada nombre es un elemento seleccionable.
    *   `ElevatedButton` / `TextField` con icono: "Añadir nuevo jugador".
*   **Estado:** Necesita la lista de todos los documentos de la colección `users`.
*   **Acciones del Usuario:**
    *   **Tocar un nombre existente:** Guarda el `userId` seleccionado en el estado de la sesión y navega a `DashboardScreen`.
    *   **Añadir nuevo jugador:** Abre un `AlertDialog` que solicita un nombre. Al confirmar, se crea un nuevo documento en `users`, se guarda el `userId` resultante y se navega a `DashboardScreen`.

**2.2. `DashboardScreen` (Pantalla Principal)**

*   **Propósito:** Servir como centro de operaciones, mostrando el estado actual de la gala, el acceso a la predicción y el ranking general.
*   **Componentes Clave:**
    *   **Header:** Saludo personalizado ("Bienvenido, [nombre del jugador]") y un botón/icono para "Cambiar de Usuario" que regresa a `PlayerSelectionScreen`.
    *   **Widget "Gala Actual":**
        *   Muestra el título (ej. "Gala 3 - Apuestas Abiertas").
        *   Contiene un `ElevatedButton` "¡Haz tu predicción!" que navega a `PredictionScreen`. Este botón estará deshabilitado o mostrará un texto alternativo (ej. "Apuestas cerradas") si la gala no está activa.
    *   **Widget "Ranking General":**
        *   Una `DataTable` o `ListView` mostrando "Posición", "Jugador" y "Puntuación Total".
        *   La fila correspondiente al usuario actual se resaltará visualmente.
    *   `BottomNavigationBar`: Con dos pestañas: "Dashboard" e "Histórico".

**2.3. `PredictionScreen` (Pantalla de Predicción)**

*   **Propósito:** Proveer un formulario claro y eficiente para que el usuario rellene y guarde su predicción para la gala activa.
*   **Componentes Clave:**
    *   Título: "Tu predicción para la Gala [número]".
    *   **Sección "Eliminado":** `RadioListTile` o `DropdownButton` para elegir entre los dos nominados.
    *   **Sección "Favorito":** `GridView` de concursantes (foto y nombre) donde se puede seleccionar solo uno.
    *   **Sección "Propuestos a Nominado":** `GridView` similar al de favoritos, pero con selección múltiple (hasta un máximo de 4). Un contador visual (ej. "2/4 seleccionados") guiará al usuario.
    *   **Sección "Asigna a los Salvados" (Aparece tras seleccionar 4 nominados):**
        *   Muestra únicamente los 4 concursantes seleccionados.
        *   Junto a cada uno, dos `IconButton` (ej. 🎓 para Profesores, 🤝 para Compañeros) para asignar los roles. La lógica de la UI impedirá asignar más de un rol de cada tipo.
    *   `ElevatedButton` "Guardar Predicción": Habilitado solo cuando el formulario esté completo y válido.
*   **Acciones del Usuario:** Al guardar, la app valida los datos, los persiste en Firestore creando/actualizando un documento en `predictions` y navega de vuelta al `DashboardScreen` mostrando un `SnackBar` de confirmación.

**2.4. `HistoryScreen` (Pantalla de Histórico)**

*   **Propósito:** Ofrecer una vista comparativa y detallada de los resultados de todas las galas pasadas.
*   **Componentes Clave:**
    *   Un `SingleChildScrollView` anidado para permitir scroll en ambas direcciones.
    *   `DataTable`:
        *   **Primera columna (fija):** Nombres de los jugadores (`displayName`).
        *   **Columnas subsiguientes:** Una columna por cada gala completada ("Gala 1", "Gala 2",...).
        *   **Última columna:** "Total".
        *   **Celdas:** Muestran el `score` de cada jugador en cada gala.
*   **Estado:** Necesita los datos de las colecciones `users`, `predictions` y `galas` (solo las completadas).

**2.5. `AdminPanelScreen` (Panel de Administración)**

*   **Propósito:** Centralizar todas las acciones exclusivas del administrador en una única interfaz funcional.
*   **Componentes Clave:**
    *   **Sección "Gestión de Gala":**
        *   `DropdownButton` para seleccionar la `galaId` a gestionar.
        *   Formulario con campos para introducir cada uno de los `results` de la gala seleccionada.
        *   `ElevatedButton` "Guardar Resultados y Calcular Puntuaciones".
    *   **Sección "Configuración Global":**
        *   `DropdownButton` para seleccionar la `activeGalaId` del documento `app_config/settings`.
        *   `ElevatedButton` "Establecer como Gala Activa".