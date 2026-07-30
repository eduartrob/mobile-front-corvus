# Mobile Application — Corvus Platform

Esta es la **Aplicación Móvil Oficial** de la plataforma **CORVUS** (Sistema Integrador de Proyectos y Gestión Académica con IA), desarrollada en Flutter para dispositivos Android e iOS.

---

## 🎯 Función en el Ecosistema CORVUS
* **Experiencia de Alumnos:** Exploración de proyectos integradores, postulación e ingreso a equipos de trabajo, creación de propuestas y mapa interactivo de Océanos Azules.
* **Experiencia de Profesores:** Gestión de proyectos asignados, revisión de propuestas enviadas por alumnos, evaluación semántica y bloqueos temáticos.
* **Notificaciones en Tiempo Real:** Recepción de alertas push vía Firebase Cloud Messaging (FCM).
* **Integración con Gateway:** Consume de forma centralizada la API REST a través del **API Gateway** (`http://<server-ip>:3000/api/v1`).

---

## ⚙️ Tecnologías & Arquitectura
* **Framework:** Flutter SDK (`^3.11.0`), Dart.
* **Gestión de Estado:** Provider / StateNotifier pattern.
* **Inyección de Dependencias:** GetIt.
* **Componentes UI:** Material Design 3, Google Fonts, Flutter SVG, Device Preview.
* **Soporte de Plataformas:** Android, iOS, Windows Desktop, Web.

---

## 🛠️ Ejecución Local Independiente

### 1. Prerrequisitos
* Flutter SDK (`>=3.11.0`)
* Android Studio / Xcode

### 2. Variables de Entorno
Crea o edita el archivo `.env` en la raíz del proyecto:
```env
BASE_URL="http://10.0.2.2:3000/api/v1"  # Para emulador de Android
# BASE_URL="http://localhost:3000/api/v1" # Para Windows Desktop / Web
```

### 3. Instalación de Dependencias
```bash
flutter pub get
```

### 4. Ejecutar en Emulador o Dispositivo
```bash
# Modo Desarrollo
flutter run

# Modo Profile / Presentación Técnica
flutter run --profile
```

---

## 📦 Compilación para Producción

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle (Play Store):**
```bash
flutter build appbundle --release
```
