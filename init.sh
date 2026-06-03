#!/usr/bin/env bash

# Colores para la terminal (hace que se vea genial y profesional)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}====================================================${NC}"
echo -e "${GREEN}    Inicializador del Laboratorio GLPI + MariaDB     ${NC}"
echo -e "${YELLOW}====================================================${NC}"

# 1. Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[ERROR] Docker no está instalado. Por favor, instálalo antes de continuar.${NC}"
    exit 1
fi

# 2. Verificar si ya existe el archivo .env
if [ -f .env ]; then
    echo -e "${YELLOW}[AVISO] El archivo .env ya existe.${NC}"
    read -p "¿Deseas sobrescribirlo con una nueva configuración? (s/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${GREEN}[INFO] Cancelado. Usando el archivo .env existente...${NC}"
        # Saltar la creación del .env e ir directo a levantar los contenedores
        CREATE_ENV=false
    else
        CREATE_ENV=true
    fi
else
    CREATE_ENV=true
fi

# 3. Crear el archivo .env basado en la plantilla si es necesario
if [ "$CREATE_ENV" = true ]; then
    if [ ! -f .env.example ]; then
        echo -e "${RED}[ERROR] No se encuentra el archivo .env.example en el directorio.${NC}"
        exit 1
    fi

    echo -e "${GREEN}[*] Generando credenciales seguras de forma automática...${NC}"
    
    # Generar contraseñas aleatorias seguras (16 caracteres alfanuméricos)
    DB_PASS=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 16)
    ROOT_PASS=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 16)

    # Copiar plantilla y reemplazar los placeholders
    cp .env.example .env
    
    # Reemplazar valores (funciona de forma nativa en Linux y macOS)
    sed -i.bak "s/cambiame_por_favor/$DB_PASS/g" .env
    sed -i.bak "s/MYSQL_ROOT_PASSWORD=yes/MYSQL_ROOT_PASSWORD=$ROOT_PASS/g" .env 2>/dev/null || true
    
    # Limpiar archivo temporal generado por sed en algunos sistemas
    rm -f .env.bak

    echo -e "${GREEN}[OK] Archivo .env configurado correctamente con contraseñas seguras.${NC}"
fi

# 4. Desplegar los contenedores
echo -e "${GREEN}[*] Levantando los servicios de Docker (GLPI & MariaDB)...${NC}"
docker compose up -d

if [ $? -eq 0 ]; then
    echo -e "${YELLOW}====================================================${NC}"
    echo -e "${GREEN}🎉 ¡Despliegue completado con éxito!${NC}"
    echo -e "${YELLOW}====================================================${NC}"
    echo -e "👉 Accede a Nginx Proxy Manager desde tu navegador: ${GREEN}http://localhost:81${NC}"
    echo -e "📝 Puedes revisar las credenciales generadas en el archivo ${YELLOW}.env${NC}"
    echo -e "🔐 Credenciales por defecto de GLPI: Usuario: ${YELLOW}glpi${NC} | Contraseña: ${YELLOW}glpi${NC}"
else
    echo -e "${RED}[ERROR] Hubo un problema al levantar los contenedores con Docker Compose.${NC}"
    exit 1
fi