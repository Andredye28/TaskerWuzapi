#!/bin/bash
echo -e "\e[31m
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
.   Procedimento entre 5 e 15 minutos - por favor, aguarde.   .
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
\e[32m
                         Criado por Andredye
\e[0m"


# Instalar Git e Go
echo "Instalando Git e Go..."
pkg install -y git golang &>/dev/null
echo "Git e Go foram instalados com sucesso."

# Clonar o repositório tasker-wuzapi
echo "Clonando o repositório tasker-wuzapi..."
git clone https://github.com/Andredye28/tasker-wuzapi &>/dev/null
echo "Repositório clonado com sucesso."

# Navegar até o diretório do projeto
cd tasker-wuzapi

# Compilar o binário do WuzAPI
echo "Compilando o binário..."
go build . &>/dev/null

# Verificar se o binário foi compilado com sucesso
if [ -f "./wuzapi" ]; then
    echo "WuzAPI foi compilado com sucesso no Termux."

    # Dar permissões de execução ao binário e ao script de inicialização
    chmod +x wuzapi
    chmod +x start_wuzapi.sh

    echo "Permissões de execução atribuídas ao WuzAPI."
else
    echo "Erro ao compilar o WuzAPI."
    exit 1
fi

# Concedendo permissões para aplicativos externos no Termux
mkdir -p ~/.termux && echo "allow-external-apps=true" >> ~/.termux/termux.properties
termux-reload-settings
echo "Permissão para aplicativos externos configurada."

# Executar WuzAPI
echo "Executando WuzAPI..."
./wuzapi
