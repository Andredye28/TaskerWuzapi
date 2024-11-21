#!/data/data/com.termux/files/usr/bin/bash

# Caminho do arquivo de log
LOG_DIR="/storage/emulated/0/Tasker/termux/logs"
LOG_FILE="${LOG_DIR}/install_wuzapi.log"

# Função para preparar o diretório e arquivo de log
prepare_log_file() {
    # Verificar se o diretório existe, se não, criar
    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
    fi

    # Se o arquivo existir, limpar seu conteúdo
    if [ -f "$LOG_FILE" ]; then
        > "$LOG_FILE"
    fi
}

# Função de log (sem output no terminal)
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Função para verificar a porta do servidor
check_server_port() {
    # Aguarda um curto período para garantir que o servidor inicie
    sleep 5
    
    # Tenta encontrar a porta do servidor WuzAPI
    local port=$(netstat -tuln | grep -E ':[0-9]+' | awk '{print $4}' | cut -d: -f2 | grep -E '^[0-9]+$' | head -n 1)
    
    if [ -n "$port" ]; then
        log_message "Porta do servidor WuzAPI detectada: $port"
    else
        log_message "Não foi possível detectar a porta do servidor WuzAPI"
    fi
}

# Preparar arquivo de log antes de iniciar
prepare_log_file

echo "##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####"
echo "##### ESTE PROCESSO PODE LEVAR ENTRE 15 A 20 MINUTOS #####"

# Instalar Git e Go
echo "Instalando Git e Go..."
if pkg install -y git golang &> /dev/null; then
    echo "Git e Go foram instalados com sucesso."
    log_message "Instalação de Git e Go: Sucesso"
else
    echo "Erro ao instalar Git e Go. Verifique sua conexão ou tente novamente."
    log_message "Instalação de Git e Go: Falha"
    exit 1
fi

# Clonar o repositório tasker-wuzapi
echo "Clonando o repositório tasker-wuzapi..."
if git clone https://github.com/Andredye28/tasker_wuzapi &> /dev/null; then
    echo "Repositório clonado com sucesso."
    log_message "Clonagem do repositório: Sucesso"
else
    echo "Erro ao clonar o repositório. Verifique o link ou sua conexão."
    log_message "Clonagem do repositório: Falha"
    exit 1
fi

# Navegar até o diretório do projeto
cd tasker_wuzapi || { 
    echo "Erro ao acessar o diretório do projeto."; 
    log_message "Acesso ao diretório do projeto: Falha"
    exit 1; 
}

# Verificar se o Go está configurado corretamente
if command -v go &> /dev/null; then
    log_message "Verificação do Go: Configurado corretamente"
else
    echo "Erro: Go não está configurado corretamente. Verifique sua instalação."
    log_message "Verificação do Go: Falha na configuração"
    exit 1
fi

# Compilar o binário do WuzAPI
echo "Compilando o binário..."
if go build . &> /dev/null; then
    echo "WuzAPI foi compilado com sucesso no Termux."
    log_message "Compilação do binário: Sucesso"
else
    echo "Erro ao compilar o WuzAPI. Verifique o código-fonte e as dependências."
    log_message "Compilação do binário: Falha"
    exit 1
fi

# Dar permissões de execução ao binário e ao script de inicialização
chmod +x wuzapi
if [ -f "./start_wuzapi.sh" ]; then
    chmod +x start_wuzapi.sh
    echo "Permissões de execução atribuídas ao WuzAPI e ao script de inicialização."
    log_message "Atribuição de permissões: Sucesso"
else
    echo "Aviso: O script de inicialização 'start_wuzapi.sh' não foi encontrado."
    log_message "Atribuição de permissões: Script de inicialização não encontrado"
fi

# Conceder permissões para aplicativos externos no Termux
echo "Configurando permissões para aplicativos externos no Termux..."
mkdir -p ~/.termux && echo "allow-external-apps=true" >> ~/.termux/termux.properties
if termux-reload-settings &> /dev/null; then
    echo "Permissões configuradas e recarregadas com sucesso."
    log_message "Configuração de permissões do Termux: Sucesso"
else
    echo "Erro ao recarregar as configurações do Termux."
    log_message "Configuração de permissões do Termux: Falha"
    exit 1
fi

# Executar WuzAPI
echo "Executando WuzAPI..."
if ./wuzapi &> /dev/null & then
    echo "WuzAPI está rodando com sucesso."
    log_message "Execução do WuzAPI: Sucesso"
    
    # Verificar porta do servidor
    check_server_port
else
    echo "Erro ao executar o WuzAPI. Verifique o binário ou as permissões."
    log_message "Execução do WuzAPI: Falha"
    exit 1
fi

echo "##### PROCESSO FINALIZADO COM SUCESSO #####"
