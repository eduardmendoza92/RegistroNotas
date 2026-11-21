# RegistroNotas

Aplicación SwiftUI para el registro de calificaciones de la materia **ETPS4**.

Incluye:

- Inicio de sesión y registro con Firebase Authentication.
- CRUD de estudiantes en Cloud Firestore.
- Listado reactivo por cuenta docente.
- Indicador de aprobación/reprobación.
- Actualización rápida sumando un punto con un toque.
- Eliminación con deslizamiento.
- Estado vacío, validaciones y mensajes de error.

## Requisitos

- macOS con Xcode 16 o posterior.
- iOS 17 o posterior.
- Un proyecto de Firebase con Authentication y Cloud Firestore habilitados.

## Configuración

1. Crea un proyecto en Firebase.
2. Registra una aplicación iOS con el Bundle ID `com.utec.RegistroNotas`.
3. Descarga `GoogleService-Info.plist`.
4. Abre el proyecto en Xcode y coloca el archivo en la carpeta `RegistroNotas/`, junto a `RegistroNotasApp.swift`.
5. En Firebase Authentication, habilita **Correo electrónico/contraseña**.
6. En Cloud Firestore, crea la base de datos y aplica las reglas de seguridad indicadas abajo.

Ejemplo seguro de reglas:

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /grades/{gradeId} {
      allow read, update, delete: if request.auth != null
        && resource.data.teacherId == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.teacherId == request.auth.uid;
    }
  }
}
```

## Uso

1. Abre `RegistroNotas.xcodeproj`.
2. Selecciona un simulador iPhone.
3. Ejecuta el proyecto.
4. Registra una cuenta docente o inicia sesión.
5. Ingresa nombre, carnet y nota, y presiona el botón `+`.
