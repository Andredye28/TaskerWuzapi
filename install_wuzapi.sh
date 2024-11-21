#!/data/data/com.termux/files/usr/bin/bash

# Definir o caminho do arquivo de log
LOG_FILE="/storage/emulated/0/Tasker/termux/logs/install_wuzapi.log"

# Função para criar diretório se não existir
create_log_directory() {
    local log_dir=$(dirname "$LOG_FILE")
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir"
        echo "Diretório de logs criado: $log_dir"
    fi
}

# Função de log
log_message() {
    create_log_directory
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Limpar o arquivo de log se existir
clear_log_file() {
    create_log_directory
    > "$LOG_FILE"
    log_message "Log file initialized"
}

# Inicializar log
clear_log_file

log_message "##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####"
log_message "##### ESTE PROCESSO PODE LEVAR ENTRE 15 A 20 MINUTOS #####"

# Verificar se os pacotes necessários estão instalados
log_message "Verificando pacotes necessários..."
if command -v git &> /dev/null && command -v go &> /dev/null; then
    log_message "Git e Go já estão instalados."
else
    log_message "Instalando Git e Go..."
    if pkg install -y git golang &>> "$LOG_FILE"; then
        log_message "Git e Go foram instalados com sucesso."
    else
        log_message "Erro ao instalar Git e Go. Verifique sua conexão ou tente novamente."
        exit 1
    fi
fi

# Clonar o repositório tasker-wuzapi
log_message "Clonando o repositório tasker-wuzapi..."
if git clone https://github.com/Andredye28/tasker_wuzapi &>> "$LOG_FILE"; then
    log_message "Repositório clonado com sucesso."
else
    log_message "Erro ao clonar o repositório. Verifique o link ou sua conexão."
    exit 1
fi

# Navegar até o diretório do projeto
cd tasker_wuzapi || { 
    log_message "Erro ao acessar o diretório do projeto."; 
    exit 1; 
}

# Verificar se o Go está configurado corretamente
if ! command -v go &>/dev/null; then
    log_message "Erro: Go não está configurado corretamente. Verifique sua instalação."
    exit 1
fi

# Compilar o binário do WuzAPI
log_message "Compilando o binário..."
if go build . &>> "$LOG_FILE"; then
    log_message "WuzAPI foi compilado com sucesso no Termux."
else
    log_message "Erro ao compilar o WuzAPI. Verifique o código-fonte e as dependências."
    exit 1
fi

# Dar permissões de execução ao binário e ao script de inicialização
chmod +x wuzapi
if [ -f "./start_wuzapi.sh" ]; then
    chmod +x start_wuzapi.sh
    log_message "Permissões de execução atribuídas ao WuzAPI e ao script de inicialização."
else
    log_message "Aviso: O script de inicialização 'start_wuzapi.sh' não foi encontrado."
fi

# Conceder permissões para aplicativos externos no Termux
log_message "Configurando permissões para aplicativos externos no Termux..."
mkdir -p ~/.termux && echo "allow-external-apps=true" >> ~/.termux/termux.properties
if termux-reload-settings &>> "$LOG_FILE"; then
    log_message "Permissões configuradas e recarregadas com sucesso."
else
    log_message "Erro ao recarregar as configurações do Termux."
    exit 1
fi

# Verificar portas ativas
log_message "Verificando portas ativas..."
active_ports=$(netstat -tuln | grep -E ':[0-9]+' | awk '{print $4}' | cut -d: -f2)
if [ -n "$active_ports" ]; then
    log_message "Portas ativas encontradas:"
    for port in $active_ports; do
        log_message "- Porta $port está ativa"
    done
else
    log_message "Nenhuma porta ativa encontrada."
fi

# Executar WuzAPI
log_message "Executando WuzAPI..."
if ./wuzapi &>> "$LOG_FILE"; then
    log_message "WuzAPI está rodando com sucesso."
else
    log_message "Erro ao executar o WuzAPI. Verifique o binário ou as permissões."
    exit 1
fi

log_message "##### PROCESSO FINALIZADO COM SUCESSO #####"
