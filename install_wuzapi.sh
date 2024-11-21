#!/data/data/com.termux/files/usr/bin/bash

# Caminho do arquivo de log
LOG_FILE="/storage/emulated/0/Tasker/termux/TASKER-WUZAPI/logs/install.log"

# Verificar e criar o arquivo de log
if [ ! -f "$LOG_FILE" ]; then
    mkdir -p "$(dirname "$LOG_FILE")" || { echo "Erro ao criar o diretório de logs."; exit 1; }
    touch "$LOG_FILE" || { echo "Erro ao criar o arquivo de log."; exit 1; }
else
    > "$LOG_FILE"  # Limpar o conteúdo do arquivo existente
fi

# Função para registrar mensagens no log sem interferir no terminal
log_message() {
    echo "$1" >> "$LOG_FILE"
}

echo "##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####"
log_message "##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####"
echo "##### ESTE PROCESSO PODE LEVAR ENTRE 15 A 20 MINUTOS #####"
log_message "##### ESTE PROCESSO PODE LEVAR ENTRE 15 A 20 MINUTOS #####"

# Instalar Git e Go
echo "Instalando Git e Go..."
log_message "Instalando Git e Go..."
if pkg install -y git golang &>/dev/null; then
    echo "Git e Go foram instalados com sucesso."
    log_message "Git e Go foram instalados com sucesso."
else
    echo "Erro ao instalar Git e Go. Verifique sua conexão ou tente novamente."
    log_message "Erro ao instalar Git e Go. Verifique sua conexão ou tente novamente."
    exit 1
fi

# Clonar o repositório tasker-wuzapi
echo "Clonando o repositório tasker-wuzapi..."
log_message "Clonando o repositório tasker-wuzapi..."
if git clone https://github.com/Andredye28/tasker_wuzapi &>/dev/null; then
    echo "Repositório clonado com sucesso."
    log_message "Repositório clonado com sucesso."
else
    echo "Erro ao clonar o repositório. Verifique o link ou sua conexão."
    log_message "Erro ao clonar o repositório. Verifique o link ou sua conexão."
    exit 1
fi

# Navegar até o diretório do projeto
echo "Acessando o diretório do projeto..."
log_message "Acessando o diretório do projeto..."
cd tasker_wuzapi || { 
    echo "Erro ao acessar o diretório do projeto."; 
    log_message "Erro ao acessar o diretório do projeto."; 
    exit 1; 
}

# Verificar se o Go está configurado corretamente
echo "Verificando configuração do Go..."
log_message "Verificando configuração do Go..."
if ! command -v go &>/dev/null; then
    echo "Erro: Go não está configurado corretamente. Verifique sua instalação."
    log_message "Erro: Go não está configurado corretamente. Verifique sua instalação."
    exit 1
fi

# Compilar o binário do WuzAPI
echo "Compilando o binário..."
log_message "Compilando o binário..."
if go build . &>/dev/null; then
    echo "WuzAPI foi compilado com sucesso no Termux."
    log_message "WuzAPI foi compilado com sucesso no Termux."
else
    echo "Erro ao compilar o WuzAPI. Verifique o código-fonte e as dependências."
    log_message "Erro ao compilar o WuzAPI. Verifique o código-fonte e as dependências."
    exit 1
fi

# Dar permissões de execução ao binário e ao script de inicialização
chmod +x wuzapi
if [ -f "./start_wuzapi.sh" ]; then
    chmod +x start_wuzapi.sh
    echo "Permissões de execução atribuídas ao WuzAPI e ao script de inicialização."
    log_message "Permissões de execução atribuídas ao WuzAPI e ao script de inicialização."
else
    echo "Aviso: O script de inicialização 'start_wuzapi.sh' não foi encontrado."
    log_message "Aviso: O script de inicialização 'start_wuzapi.sh' não foi encontrado."
fi

# Conceder permissões para aplicativos externos no Termux
echo "Configurando permissões para aplicativos externos no Termux..."
log_message "Configurando permissões para aplicativos externos no Termux..."
mkdir -p ~/.termux && echo "allow-external-apps=true" >> ~/.termux/termux.properties
if termux-reload-settings; then
    echo "Permissões configuradas e recarregadas com sucesso."
    log_message "Permissões configuradas e recarregadas com sucesso."
else
    echo "Erro ao recarregar as configurações do Termux."
    log_message "Erro ao recarregar as configurações do Termux."
    exit 1
fi

# Executar WuzAPI
echo "Executando WuzAPI..."
log_message "Executando WuzAPI..."
if ./wuzapi; then
    echo "WuzAPI está rodando com sucesso."
    log_message "WuzAPI está rodando com sucesso."
else
    echo "Erro ao executar o WuzAPI. Verifique o binário ou as permissões."
    log_message "Erro ao executar o WuzAPI. Verifique o binário ou as permissões."
    exit 1
fi

echo "##### PROCESSO FINALIZADO COM SUCESSO #####"
log_message "##### PROCESSO FINALIZADO COM SUCESSO #####"
