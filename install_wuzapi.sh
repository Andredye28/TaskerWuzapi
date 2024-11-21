#!/data/data/com.termux/files/usr/bin/bash

# Caminho do log
LOG_PATH="/storage/emulated/0/Tasker/termux/TASKER-WUZAPI/logs/install.log"

# Verificar se o arquivo de log existe
if [ ! -f "$LOG_PATH" ]; then
    echo "Criando diretório e arquivo de log..."
    mkdir -p "$(dirname "$LOG_PATH")" && touch "$LOG_PATH"
else
    echo "Limpando o arquivo de log existente..."
    > "$LOG_PATH"
fi

# Função para gravar logs
log() {
    echo "$1" >> "$LOG_PATH"
}

# Início do script
echo "##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####"
log "##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####"
log "##### ESTE PROCESSO PODE LEVAR ENTRE 15 A 20 MINUTOS #####"

# Instalar Git e Go
echo "Instalando Git e Go..."
log "Instalando Git e Go..."
if pkg install -y git golang &>/dev/null; then
    echo "Git e Go foram instalados com sucesso."
    log "Git e Go foram instalados com sucesso."
else
    echo "Erro ao instalar Git e Go. Verifique sua conexão ou tente novamente."
    log "Erro ao instalar Git e Go. Verifique sua conexão ou tente novamente."
    exit 1
fi

# Clonar o repositório tasker-wuzapi
echo "Clonando o repositório tasker-wuzapi..."
log "Clonando o repositório tasker-wuzapi..."
if git clone https://github.com/Andredye28/tasker_wuzapi &>/dev/null; then
    echo "Repositório clonado com sucesso."
    log "Repositório clonado com sucesso."
else
    echo "Erro ao clonar o repositório. Verifique o link ou sua conexão."
    log "Erro ao clonar o repositório. Verifique o link ou sua conexão."
    exit 1
fi

# Navegar até o diretório do projeto
cd tasker_wuzapi || { 
    echo "Erro ao acessar o diretório do projeto."
    log "Erro ao acessar o diretório do projeto."
    exit 1
}

# Verificar se o Go está configurado corretamente
if ! command -v go &>/dev/null; then
    echo "Erro: Go não está configurado corretamente. Verifique sua instalação."
    log "Erro: Go não está configurado corretamente. Verifique sua instalação."
    exit 1
fi

# Compilar o binário do WuzAPI
echo "Compilando o binário..."
log "Compilando o binário..."
if go build . &>/dev/null; then
    echo "WuzAPI foi compilado com sucesso no Termux."
    log "WuzAPI foi compilado com sucesso no Termux."
else
    echo "Erro ao compilar o WuzAPI. Verifique o código-fonte e as dependências."
    log "Erro ao compilar o WuzAPI. Verifique o código-fonte e as dependências."
    exit 1
fi

# Dar permissões de execução ao binário e ao script de inicialização
chmod +x wuzapi
if [ -f "./start_wuzapi.sh" ]; then
    chmod +x start_wuzapi.sh
    echo "Permissões de execução atribuídas ao WuzAPI e ao script de inicialização."
    log "Permissões de execução atribuídas ao WuzAPI e ao script de inicialização."
else
    echo "Aviso: O script de inicialização 'start_wuzapi.sh' não foi encontrado."
    log "Aviso: O script de inicialização 'start_wuzapi.sh' não foi encontrado."
fi

# Conceder permissões para aplicativos externos no Termux
echo "Configurando permissões para aplicativos externos no Termux..."
log "Configurando permissões para aplicativos externos no Termux..."
mkdir -p ~/.termux && echo "allow-external-apps=true" >> ~/.termux/termux.properties
if termux-reload-settings; then
    echo "Permissões configuradas e recarregadas com sucesso."
    log "Permissões configuradas e recarregadas com sucesso."
else
    echo "Erro ao recarregar as configurações do Termux."
    log "Erro ao recarregar as configurações do Termux."
    exit 1
fi

# Executar WuzAPI
echo "Executando WuzAPI..."
log "Executando WuzAPI..."
if ./wuzapi; then
    echo "WuzAPI está rodando com sucesso."
    log "WuzAPI está rodando com sucesso."
else
    echo "Erro ao executar o WuzAPI. Verifique o binário ou as permissões."
    log "Erro ao executar o WuzAPI. Verifique o binário ou as permissões."
    exit 1
fi

echo "##### PROCESSO FINALIZADO COM SUCESSO #####"
log "##### PROCESSO FINALIZADO COM SUCESSO #####"
