### **Documento Técnico: Especificación Funcional y de Producto**

**Proyecto:** PorrOT 2025 (Versión 1.0)

---

#### **1. Visión del Producto**

La aplicación "PorrOT 2025" es una herramienta digital, implementada como web/mobile app con Flutter, diseñada para organizar y ludificar una competición privada entre amigos basada en el concurso televisivo Operación Triunfo.

El objetivo principal es reemplazar sistemas manuales (hojas de cálculo, grupos de chat) por una plataforma centralizada que automatiza la recogida de predicciones, el cálculo de puntuaciones y la visualización de clasificaciones, potenciando la experiencia social y competitiva de seguir el programa. La simplicidad de uso, la claridad de la información y la agilidad en la gestión son los pilares fundamentales del producto.

#### **2. Roles de Usuario**

La aplicación define dos roles con permisos diferenciados:

*   **2.1. Jugador:**
    *   Es el rol por defecto para cualquier participante.
    *   Puede seleccionar su perfil de una lista preexistente o crear uno nuevo para la sesión actual.
    *   Puede enviar y modificar su predicción para la gala que se encuentre activa.
    *   Puede consultar la clasificación general en tiempo real.
    *   Puede consultar el histórico de puntuaciones de todas las galas pasadas.

*   **2.2. Administrador:**
    *   Es un Jugador con capacidades extendidas.
    *   Hereda todos los permisos del rol de Jugador.
    *   Tiene acceso a un panel de administración para gestionar el estado del juego (se asume que solo participantes de confianza tendrán acceso a esta funcionalidad).
    *   Tiene la capacidad de introducir los resultados oficiales de cada gala.
    *   Es responsable de iniciar el proceso de cálculo de puntuaciones una vez finalizada una gala.
    *   Controla cuál es la "gala activa" en la que los jugadores pueden realizar sus predicciones.
    *   Puede actualizar los estados de los concursantes tras cada gala (activo, nominado, eliminado, ganador).

#### **3. Flujos de Usuario Principales**

**3.1. Flujo de "Identificación por Sesión"**
1.  Al iniciar la aplicación, el usuario es presentado con una pantalla de selección.
2.  Esta pantalla muestra una lista de todos los jugadores ya registrados.
3.  El usuario selecciona su nombre de la lista para iniciar su sesión.
4.  Si su nombre no aparece, puede optar por "Añadir nuevo jugador", introducir su nombre y ser añadido a la lista para futuras sesiones.
5.  Una vez seleccionado, la aplicación recordará su identidad durante la sesión y lo llevará a la pantalla principal.

**3.2. Flujo de "Realizar una Predicción Semanal"**
1.  Desde la pantalla principal, si una gala está "activa", el Jugador pulsa el botón para realizar su predicción.
2.  Se le presenta un formulario claro con las siguientes secciones a rellenar:
    *   **Eliminado:** Selección entre los dos concursantes nominados de la semana anterior.
    *   **Favorito:** Selección de un único concursante de entre todos los activos.
    *   **Propuestos a Nominado:** Selección de exactamente cuatro concursantes.
3.  Tras seleccionar los cuatro propuestos, se le muestra una sección adicional para asignar roles a dos de ellos:
    *   "Salvado por los Profesores".
    *   "Salvado por los Compañeros".
4.  Una vez completados todos los campos, el Jugador guarda su predicción. El sistema la almacena y le devuelve a la pantalla principal con una confirmación.

**3.3. Flujo de "Consultar Clasificación e Histórico"**
1.  Desde la pantalla principal, el Jugador puede ver un resumen del ranking general.
2.  Puede navegar a la sección "Histórico".
3.  Se le presenta una tabla o matriz donde:
    *   Las filas representan a cada Jugador.
    *   Las columnas representan cada una de las galas ya completadas.
    *   Las celdas muestran la puntuación obtenida por cada Jugador en cada gala.
    *   Una columna final muestra la puntuación total acumulada.

**3.4. Flujo de "Administración de Gala"**
1.  El Administrador accede al Panel de Administración.
2.  Selecciona la gala que desea gestionar.
3.  Introduce los resultados oficiales en un formulario (quién fue el favorito real, el eliminado, los cuatro propuestos, los dos salvados, etc.).
4.  Pulsa el botón "Calcular Puntuaciones". La aplicación procesa todas las predicciones para esa gala y actualiza los marcadores.
5.  El Administrador designa cuál será la siguiente "gala activa" para abrir el ciclo de predicciones de la nueva semana.

#### **4. Desglose de Funcionalidades (Features)**

*   **4.1. Módulo de Predicción:**
    *   **Entrada de Datos:** Formulario compuesto por selectores para las categorías: Eliminado, Favorito, Propuestos a Nominado (4).
    *   **Lógica de Selección:** La selección de Favorito y Propuestos a Nominado se realizará sobre una lista de concursantes activos. La selección de Eliminado se hará sobre los dos nominados de la gala anterior.
    *   **Asignación de Salvados:** Mecanismo de "Asignación Post-Selección" que permite asignar los roles de "Salvado por Profesores" y "Salvado por Compañeros" de forma explícita a dos de los cuatro propuestos seleccionados.

*   **4.2. Módulo de Ranking (Dashboard):**
    *   Visualización de una lista ordenada de Jugadores basada en su puntuación total acumulada, de mayor a menor.
    *   Debe destacar visiblemente la posición del Jugador que está usando la aplicación en ese momento.

*   **4.3. Módulo de Histórico:**
    *   Presentación de datos en una vista de matriz bidimensional (Jugadores x Galas).
    *   Permitirá el scroll horizontal si el número de galas excede el ancho de la pantalla.
    *   Incluirá una columna de "Total" para la suma de puntuaciones por jugador.

*   **4.4. Panel de Administración:**
    *   **Selector de Gala a Gestionar:** Permite al admin rellenar los resultados de cualquier gala en cualquier momento.
    *   **Formulario de Resultados:** Campos de entrada para cada dato oficial de la gala.
    *   **Disparador de Cálculo:** Un botón para iniciar el proceso de cálculo de puntos para la gala seleccionada.
    *   **Selector de Gala Activa:** Un control para definir qué gala está abierta a nuevas predicciones por parte de los Jugadores.