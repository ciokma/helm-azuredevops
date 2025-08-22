🚀 Flujo típico en VS Code

# Instalas Azure Functions extension.

# Ctrl+Shift+P → Azure Functions: Create New Project

# Seleccionas:

# Lenguaje (Node, Python, C#, etc.)

# Plantilla (HTTP trigger, Timer, etc.)

# Corres localmente con F5.

# Publicas con clic derecho → Deploy to Function App.

# macOS/Linux
npm install -g azure-functions-core-tools@4 --unsafe-perm true

# Windows (PowerShell)
npm install -g azure-functions-core-tools@4 --unsafe-perm true
func --version
# Ejecuta desde la raíz:
func start --custom


# test
curl -X POST http://localhost:7071/api/QdrantSnapshot -H "Content-Type: application/json" -d '{"name":"Carlos"}'

Estructura final esperada
qdrant-snapshot-script/
│   host.json
└───QdrantSnapshot/
    │   function.json
    │   qdrant_volume_snapshot.sh

# Publicar en Azure
En la barra lateral de Azure Functions, haz clic derecho sobre tu Function App → Deploy to Function App.

Selecciona o crea una Function App en Azure.

VS Code subirá todo, incluyendo tu script Bash, y lo ejecutará como Custom Handler.

🔹 Nota

En producción, si el script hace snapshots largos, considera Timer Trigger en vez de HTTP Trigger.

El Custom Handler debe responder rápido al runtime. Todo lo largo o pesado debe ir en background o en un contenedor independiente.

#instalar azurite para local storage
npm install -g azurite


🔹 Soluciones locales
Opción 1️⃣ Instalar y levantar Azurite

Instala Azurite:

npm install -g azurite


Ejecuta Azurite en otra terminal:

azurite --silent --location ~/azurite --debug ~/azurite/debug.log


Esto inicia Blob Storage local en 127.0.0.1:10000.

Ahora func start --custom podrá iniciar el listener del Timer Trigger.