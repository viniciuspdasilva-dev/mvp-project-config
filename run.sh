#!/bin/bash

#Verifica se o Docker e o docker-compose estão instalados
if ! command -v docker &> /dev/null
then
  echo "[ERR] Docker não está instalado."
  exit 1
fi

if ! command -v docker-compose &> /dev/null
then
  echo "[ERR] Docker não está instalado."
  exit 1
fi

# Lista de projetos
PROJECTS=("mvp-payment-service-api" "mvp-inventory-service-api" "mvp-order-service-api")

echo "Inicializando os serviços compartilhados..."
docker compose -f docker-compose.yml up -d

# Loop para iniciar os projetos e rodá-los em container
for PROJECT in "${PROJECTS[@]}"; do
    if [ ! -d "$PROJECT" ]; then
        echo "Clonando projeto $PROJECT..."
        git clone https://github.com/viniciuspdasilva-dev/$PROJECT.git
    fi

    echo "Subindo o container do projeto $PROJECT..."
    cd "$PROJECT" || exit 1

    # Garante que a rede compartilhada existe
    if ! docker network inspect net-mvp-saga >/dev/null 2>&1; then
        docker network create --subnet=10.200.0.0/24 net-mvp-saga
    fi

    docker compose up -d
    cd ..
done
