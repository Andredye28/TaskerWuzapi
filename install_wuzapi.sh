#!/data/data/com.termux/files/usr/bin/bash

# Caminho para o arquivo de log
LOG_DIR="/storage/emulated/0/Tasker/termux/TASKER-WUZAPI/logs"
LOG_FILE="$LOG_DIR/install.log"

# Criar diretório e arquivo de log, limpar se já existir
mkdir -p "$LOG_DIR"
> "$LOG_FILE"

# Função para registrar logs
log() {
    echo "$1" >> "$LOG_FILE"
}

echo "##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####"
echo "##### ESTE PROCESSO PODE LEVAR ENTRE 5 A 10 MINUTOS #####"

# Instalar Git e Go
echo "Instalando Git e Go..."
log "Iniciando a instalação de Git e Go..."
if pkg install -y git golang &>/dev/null; then
    echo "Git e Go foram instalados com sucesso."
    log "Git e Go foram instalados com sucesso."
else
    echo "Erro ao instalar Git e Go. Verifique sua conexão ou tente novamente."
    log "Erro ao instalar Git e Go."
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
    log "Erro ao clonar o repositório."
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
    log "Erro: Go não configurado corretamente."
    exit 1
fi

# Compilar o binário do WuzAPI
echo "Compilando o binário..."
log "Iniciando a compilação do binário..."
if go build . &>/dev/null; then
    echo "WuzAPI foi compilado com sucesso no Termux."
    log "WuzAPI compilado com sucesso."
else
    echo "Erro ao compilar o WuzAPI. Verifique o código-fonte e as dependências."
    log "Erro ao compilar o WuzAPI."
    exit 1
fi

# Dar permissões de execução ao binário e ao script de inicialização
chmod +x wuzapi
if [ -f "./start_wuzapi.sh" ]; then
    chmod +x start_wuzapi.sh
    echo "Permissões de execução atribuídas ao WuzAPI e ao script de inicialização."
    log "Permissões atribuídas ao WuzAPI e ao script de inicialização."
else
    echo "Aviso: O script de inicialização 'start_wuzapi.sh' não foi encontrado."
    log "Aviso: Script de inicialização não encontrado."
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

# Executar WuzAPI e capturar mensagem do servidor
echo "Executando WuzAPI..."
log "Iniciando o WuzAPI..."
OUTPUT=$(./wuzapi 2>&1)
echo "$OUTPUT"
echo "$OUTPUT" >> "$LOG_FILE"

if echo "$OUTPUT" | grep -q "Server Started"; then
    echo "Servidor ativo."
    log "Servidor ativo."
else
    echo "Erro ao executar o WuzAPI. Verifique o binário ou as permissões."
    log "Erro ao executar o WuzAPI."
    exit 1
fi

echo "##### PROCESSO FINALIZADO COM SUCESSO #####"
log "##### PROCESSO FINALIZADO COM SUCESSO #####"
