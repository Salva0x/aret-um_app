# Aretéum App ✨

¡Bienvenido/a al repositorio de Aretéum! Esta es una aplicación móvil desarrollada con Flutter, pensada para facilitar la gestión y reserva de eventos y actividades.

## Acerca del Proyecto 🚀

Aretéum nace con la idea de ofrecer una plataforma centralizada donde los usuarios puedan descubrir eventos de su interés, consultar detalles, reservar su plaza y gestionar su perfil de una manera sencilla y ágil. Por otro lado, proporciona a los administradores las herramientas necesarias para gestionar tanto los eventos como los usuarios de la plataforma.

El objetivo principal es crear una experiencia de usuario fluida y agradable, con una interfaz limpia y funcionalidades que realmente aporten valor.

## Características Principales 📋

*   **Autenticación de Usuarios:**
    *   Registro de nuevas cuentas.
    *   Inicio de sesión seguro.
    *   Opción para recuperar contraseña.
*   **Gestión de Eventos (Usuarios):**
    *   Exploración de eventos disponibles (con vista de calendario y listado).
    *   Visualización detallada de cada evento (descripción, fecha, ponente, ubicación, aforo).
    *   Sistema de reserva y cancelación de plazas.
    *   Sección "Mis Reservas" para consultar eventos reservados.
*   **Gestión de Perfil:**
    *   Visualización y edición de datos personales (nombre, teléfono, NIF).
    *   Cambio de contraseña.
    *   Subida y eliminación de foto de perfil.
*   **Búsqueda:**
    *   Funcionalidad de búsqueda integrada para encontrar eventos específicos.
*   **Panel de Administración (para usuarios con rol de administrador):**
    *   Gestión de usuarios (visualizar, editar roles - *funcionalidad futura*).
    *   Gestión de eventos (crear, editar, eliminar eventos, ver participantes).
*   **Diseño Consistente:**
    *   Interfaz de usuario unificada con una paleta de colores y estilos coherentes a través de toda la aplicación.

## Capturas de Pantalla 📸

| Login Screen                                   | Home Screen                                  | Event Detail                                     |
| :--------------------------------------------: | :------------------------------------------: | :----------------------------------------------: |
| ![Login](https://github.com/user-attachments/assets/37ed51c8-3ab3-43bf-aa95-547b6a338b66) | ![Home](https://github.com/user-attachments/assets/46ab3949-826f-41ce-8f71-b14306915084) | ![Event](https://github.com/user-attachments/assets/221dafac-5c47-42ea-b831-ae1a81afe799) |

## Tecnologías Utilizadas 🛠️

*   **Flutter (Dart):** Framework principal para el desarrollo de la interfaz de usuario multiplataforma.
*   **Firebase:**
    *   **Firebase Authentication:** Para la gestión de la autenticación de usuarios.
    *   **Cloud Firestore:** Como base de datos NoSQL para almacenar información de eventos, usuarios, reservas, etc.
    *   **Firebase Storage:** Para el almacenamiento de archivos, como las fotos de perfil de los usuarios.
*   **Plugins de Flutter notables:**
    *   `cloud_firestore`
    *   `firebase_auth`
    *   `firebase_storage`
    *   `intl`: Para formateo de fechas y localización.
    *   `image_picker`: Para seleccionar imágenes de la galería o cámara.

## Empezando 🚀

Sigue estos pasos para tener una copia del proyecto funcionando en tu máquina local para desarrollo y pruebas.

### Pre-requisitos

*   Tener Flutter SDK instalado. Puedes encontrar la guía de instalación [aquí](https://flutter.dev/docs/get-started/install).
*   Un editor de código como VS Code o Android Studio.
*   Un emulador de Android/iOS configurado o un dispositivo físico.

### Instalación

1.  **Clona el repositorio:**
    ```bash
    git clone https://github.com/Salva0x/areteum_app.git
    ```
2.  **Navega al directorio del proyecto:**
    ```bash
    cd areteum_app
    ```
3.  **Instala las dependencias:**
    ```bash
    flutter pub get
    ```
4.  **Configuración de Firebase:**
    *   Crea un proyecto en la [Firebase Console](https://console.firebase.google.com/).
    *   Registra tu aplicación (Android y/o iOS) dentro de tu proyecto de Firebase.
    *   Descarga los archivos de configuración y colócalos en las rutas correspondientes:
        *   Para Android: `android/app/google-services.json`
        *   Para iOS: `ios/Runner/GoogleService-Info.plist` (Asegúrate de abrir el proyecto de iOS en Xcode para añadir este archivo correctamente).
    *   En la Firebase Console, habilita los siguientes servicios:
        *   **Authentication:** Habilita el proveedor de "Correo electrónico/Contraseña".
        *   **Cloud Firestore:** Crea una base de datos. Puedes empezar en modo de prueba, pero recuerda configurar las reglas de seguridad adecuadamente para producción.
        *   **Firebase Storage:** Configura un bucket de almacenamiento.
    *   **Reglas de Seguridad:** Es crucial que configures las reglas de seguridad para Firestore y Storage para proteger los datos de tus usuarios. Por ejemplo, permitir que los usuarios solo lean/escriban sus propios datos, y que los administradores tengan permisos más amplios.

5.  **Ejecuta la aplicación:**
    ```bash
    flutter run
    ```

## Estructura del Proyecto 📂 (Simplificada)
```
areteum_app/
├── android/ # Configuración específica de Android
├── ios/ # Configuración específica de iOS
├── lib/
│ ├── main.dart # Punto de entrada de la aplicación
│ ├── models/ # Modelos de datos (User, Event, Space, etc.)
│ ├── screens/ # Widgets que representan cada pantalla de la app
│ ├── services/ # Lógica de negocio, servicios (ej. FirebaseService)
│ ├── widgets/ # Widgets reutilizables (Footer, CustomSearchDelegate, etc.)
│ └── utils/ # Utilidades, constantes, helpers (si aplica)
├── assets/ # Recursos estáticos como imágenes, fuentes
│ └── logo.png
│ └── perfil.png
└── pubspec.yaml # Manifiesto del proyecto, dependencias
```

## Contribuciones 🤝

¡Las contribuciones son bienvenidas! Si tienes alguna idea para mejorar la aplicación o encuentras algún error, no dudes en:

1.  Hacer un Fork del proyecto.
2.  Crear una nueva rama para tu funcionalidad (`git checkout -b feature/AmazingFeature`).
3.  Realizar tus cambios y hacer commit (`git commit -m 'Add some AmazingFeature'`).
4.  Hacer Push a la rama (`git push origin feature/AmazingFeature`).
5.  Abrir un Pull Request.

Por favor, asegúrate de que tu código sigue las guías de estilo y de que los tests (si los hay) pasan.

## Licencia 📄

Este proyecto está distribuido bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.

## Contacto 📬

Salvador Martínez Santos  - salva.martinez.dam@gmail.com

Enlace al Proyecto: [https://github.com/Salva0x/areteum_app](https://github.com/Salva0x/areteum_app)

---

¡Gracias por echar un vistazo a Aretéum! Espero que te sea útil.
