# Elasticsearch con APM - Docker Compose

Este proyecto configura un stack completo de Elasticsearch con APM (Application Performance Monitoring) usando Docker Compose.

## Componentes

- **Elasticsearch**: Motor de búsqueda y análisis
- **Kibana**: Interfaz web para visualización y gestión
- **APM Server**: Servidor para recibir datos de APM de las aplicaciones

## Configuración

### 1. Crear archivo .env

Crea un archivo `.env` en la raíz del proyecto con el siguiente contenido:

```bash
# Versión del stack de Elastic
STACK_VERSION=8.11.0

# Contraseña para el usuario elastic (cambia esto por una contraseña segura)
ELASTIC_PASSWORD=changeme

# Contraseña para el usuario kibana_system (cambia esto por una contraseña segura)
KIBANA_SYSTEM_PASSWORD=changeme

# Token secreto para APM (cambia esto por un token seguro)
APM_SECRET_TOKEN=your-secret-token-here
```

### 2. Iniciar los servicios

```bash
docker-compose up -d
```

### 3. Verificar que todo esté funcionando

```bash
# Verificar estado de los contenedores
docker-compose ps

# Ver logs de Elasticsearch
docker-compose logs elasticsearch

# Ver logs de Kibana
docker-compose logs kibana

# Ver logs de APM Server
docker-compose logs apm-server
```

## Acceso a los servicios

- **Elasticsearch**: http://localhost:9200
- **Kibana**: http://localhost:5601
- **APM Server**: http://localhost:8200

## Credenciales

- **Usuario**: `elastic`
- **Contraseña**: La que configuraste en `ELASTIC_PASSWORD`

## Configurar APM en tu aplicación

### Para Node.js

```bash
npm install @elastic/apm-agent-nodejs
```

```javascript
const apm = require('@elastic/apm-agent-nodejs').start({
  serviceName: 'mi-aplicacion',
  serverUrl: 'http://localhost:8200',
  secretToken: 'your-secret-token-here'
})
```

### Para Python

```bash
pip install elastic-apm
```

```python
import elasticapm

elasticapm.init(
    service_name='mi-aplicacion',
    server_url='http://localhost:8200',
    secret_token='your-secret-token-here'
)
```

### Para Java

```xml
<dependency>
    <groupId>co.elastic.apm</groupId>
    <artifactId>apm-agent-api</artifactId>
    <version>1.36.0</version>
</dependency>
```

```java
// En tu aplicación
elastic.apm.service_name=mi-aplicacion
elastic.apm.server_url=http://localhost:8200
elastic.apm.secret_token=your-secret-token-here
```

## Comandos útiles

```bash
# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes (¡CUIDADO! Esto borra todos los datos)
docker-compose down -v

# Ver logs en tiempo real
docker-compose logs -f

# Reiniciar un servicio específico
docker-compose restart elasticsearch
```

## Troubleshooting

### Si Elasticsearch no inicia

1. Verifica que tengas suficiente memoria disponible (mínimo 2GB)
2. Ajusta la configuración de memoria en el docker-compose.yml si es necesario
3. Verifica los logs: `docker-compose logs elasticsearch`

### Si Kibana no puede conectarse a Elasticsearch

1. Espera a que Elasticsearch esté completamente iniciado
2. Verifica que las credenciales en el archivo .env sean correctas
3. Verifica los logs: `docker-compose logs kibana`

### Si APM Server no funciona

1. Verifica que el token secreto esté configurado correctamente
2. Asegúrate de que tu aplicación esté enviando datos al puerto correcto (8200)
3. Verifica los logs: `docker-compose logs apm-server`

## Seguridad

⚠️ **Importante**: Esta configuración está optimizada para desarrollo local. Para producción:

1. Cambia todas las contraseñas por valores seguros
2. Habilita TLS/SSL
3. Configura firewalls apropiados
4. Usa secrets management para las credenciales
5. Considera usar Elastic Cloud para un entorno más seguro
