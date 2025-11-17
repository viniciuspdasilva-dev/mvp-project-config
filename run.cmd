@echo off
setlocal enabledelayedexpansion

REM Verifica se o Docker e docker compose existem na maquina do usuario
where docker >nul 2>&1
if errorlevel 1 (
    echo [ERR] Docker not installed.
    exit /b 1
)

where docker-compose >nul 2>&1
if errorlevel 1 (
    echo [ERR] Docker compose not installed.
    exit /b 1
)

REM Lista de projetos
set PROJECTS=mvp-payment-service-api mvp-inventory-service-api mvp-order-service-api

echo Inicializando os serviços compartilhados...
docker compose -f docker-compose.yml up -d

REM Loop para iniciar os projetos e roda-los em container
for %%p in (%PROJECTS%) do (
    if not exists %%p (
        echo Clonando projeto %%p...
        git clone https://github.com/viniciuspdasilva-dev/%%p.git
    )
    echo Subindo o container do projeto %%p...
    cd %%p
    REM Garante que a rede compartilhada existe
    docker network inspect net-mvp-saga >nul 2>&1
    if errorlevel 1 (
        docker network create --subnet=10.200.0.0/24 net-mvp-saga
    )

    docker compose up -d
    cd ..
)
