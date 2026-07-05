El problema que estamos viendo (el error 401 y 500 al sincronizar) se debe a que la API de Google Drive rechaza el token para ciertas carpetas, a pesar de que el token debería ser válido para todas.

Para poder arreglarlo definitivamente, necesito ver si el token se está perdiendo a mitad del proceso.
¿Podrías hacer una última prueba en la cuenta del **Profesor**?
1. Cierra sesión en tu cuenta de alumno e inicia sesión con la cuenta del profesor (`thegreatteachertester@gmail.com`).
2. Ve a los ajustes del profesor y presiona el botón **Sincronizar Google Classroom**.
3. Espera unos segundos a que termine el proceso (seguro algunas fallarán).
4. Envíame los **logs del servidor backend** (`clustering-subject-service`) donde aparezcan los mensajes de `DEBUG: Requesting Drive API for folder...`.

Con esto podré implementar la solución final para que todas las clases se sincronicen correctamente.
