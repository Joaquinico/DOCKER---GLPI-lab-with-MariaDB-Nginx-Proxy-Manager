🚀 Laboratorio de GLPI en Docker con MariaDB y Nginx Proxy Manager
¡Bienvenido! Este repositorio contiene una plantilla lista para desplegar un entorno de laboratorio completo de GLPI (v11), respaldado por una base de datos MariaDB y protegido por el proxy inverso Nginx Proxy Manager (NPM).

Esta arquitectura emula un entorno de producción, aislando los contenedores y centralizando todo el tráfico web a través de los puertos estándar (80 y 443).

🛠️ Requisitos Previos
Antes de comenzar, asegúrate de tener instalado en tu equipo:

	Linux: Docker y Docker Compose.

	Windows / macOS: Docker Desktop iniciado.

Clona el repositorio y entra a la carpeta:
git clone https://github.com/tu-usuario/tu-repo.git
cd tu-repo

Método 1: Despliegue Automatizado usando el script init.sh:
Si estás en Linux, macOS o usas Git Bash / WSL en Windows, puedes desplegar todo el laboratorio con un solo comando. 
El script validará tu entorno, generará contraseñas aleatorias seguras en tu archivo .env automáticamente y levantará los servicios.

Dale permisos de ejecución al script:
	chmod +x init.sh

Ejecuta el script:
	./init.sh

Método 2: Despliegue Manual (Paso a Paso)
Si prefieres configurar las contraseñas tú mismo o estás usando Windows (CMD/PowerShell):

Crear el archivo de configuración de entorno:
	Copia la plantilla .env.example y renómbrala como .env:
		Linux / macOS / Git Bash: cp .env.example .env
		Windows CMD: copy .env.example .env
		Windows PowerShell: cp .env.example .env

	Configurar contraseñas: Abre el archivo .env recién creado con tu editor de texto favorito y cambia los valores 	genéricos por tus propias contraseñas seguras.

Levantar los contenedores:
docker compose up -d

Configuración del Proxy Inverso (Nginx Proxy Manager)
Una vez levantados los contenedores, el acceso a GLPI se gestiona a través de Nginx Proxy Manager.

	Entra al panel de administración de NPM: http://localhost:81

	Inicia sesión con las credenciales por defecto:

		Usuario: admin@example.com
		Contraseña: changeme
* Nota: El sistema te obligará a cambiar el email y la contraseña inmediatamente en el primer inicio.

Redirección hacia GLPI:
Para mapear que tu tráfico local (http://localhost) vaya directo a GLPI sin necesidad de escribir puertos raros:

	Ve a Hosts > Proxy Hosts y haz clic en Add Proxy Host.

	Configura los siguientes campos en la pestaña Details:

		Domain Names: localhost (o el dominio local que uses en tu archivo hosts).

		Scheme: http

		Forward Hostname / IP: contenedor_glpi (Docker resolverá este nombre internamente).

		Forward Port: 80

		Activa Block Common Exploits para añadir una capa extra de seguridad.

		Haz clic en Save.

¡Listo! Ahora puedes acceder a tu GLPI simplemente entrando a http://localhost.

Credenciales por Defecto de GLPI
Cuando accedas por primera vez a http://localhost, sigue el asistente de instalación. Una vez finalizado, puedes iniciar sesión con las siguientes cuentas integradas:

	glpi / glpi -> Administrador total (Super-Admin)

	tech / tech -> Técnico de soporte

	normal / normal -> Usuario estándar de la interfaz

	post-only / postonly -> Usuario limitado (Solo creación de tickets)

* IMPORTANTE: Por motivos de seguridad, cambia la contraseña del usuario glpi o desactiva las cuentas por defecto en entornos de pruebas compartidos.

Persistencia de Datos (Volúmenes)
Para evitar la pérdida de información al reiniciar o destruir los contenedores, los datos se almacenan en volúmenes gestionados internamente por Docker:

	db_data: Almacena de forma persistente las tablas, configuraciones e histórico de la base de datos MariaDB 	(/var/lib/mysql).

	glpi_data: Conserva los archivos, documentos adjuntos, plugins y sesiones del servidor web de GLPI (/var/glpi/).

Las configuraciones de Nginx Proxy Manager se guardan localmente en las carpetas de tu proyecto ./npm-data y ./npm-letsencrypt.

Copia de Seguridad Básica (Backup SQL)
Si quieres realizar un respaldo manual de la base de datos de tu laboratorio directamente desde la línea de comandos sin detener el entorno, ejecuta:

	docker exec mariadb-glpi-lab mysqldump -u tu_usuario_db -p tu_contraseña_db nombre_de_tu_db > backup_laboratorio.sql

	(Reemplaza los valores de usuario, contraseña y base de datos por los que configuraste en tu archivo .env).