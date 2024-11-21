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

# Função para registrar mensagens no log
log_message() {
    echo "$1" >> "$LOG_FILE"
}

echo "##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####"
log_message "##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####"
echo "##### ESTE PROCESSO PODE LEVAR ENTRE 15 A 20 MINUTOS #####"
log_message "##### ESTE PROCESSO PODE LEVAR ENTRE 15 A 20 MINUTOS #####"

# Instalar Git
echo "Verificando a presença do Git..."
log_message "Verificando a presença do Git..."
if command -v git &>/dev/null; then
    echo "Git já está instalado."
    log_message "Git já está instalado."
else
    echo "Git não encontrado. Instalando..."
    log_message "Git não encontrado. Instalando..."
    if pkg install -y git &>/dev/null; then
        echo "Git instalado com sucesso."
        log_message "Git instalado com sucesso."
    else
        echo "Erro ao instalar o Git."
        log_message "Erro ao instalar o Git."
        exit 1
    fi
fi

# Instalar Go
echo "Verificando a presença do Go..."
log_message "Verificando a presença do Go..."
if command -v go &>/dev/null; then
    echo "Go já está instalado."
    log_message "Go já está instalado."
else
    echo "Go não encontrado. Instalando..."
    log_message "Go não encontrado. Instalando..."
    if pkg install -y golang &>/dev/null; then
        echo "Go instalado com sucesso."
        log_message "Go instalado com sucesso."
    else
        echo "Erro ao instalar o Go."
        log_message "Erro ao instalar o Go."
        exit 1
    fi
fi

# Instalar Netcat ou alternativas
echo "Instalando Netcat (nc) ou alternativas..."
log_message "Instalando Netcat (nc) ou alternativas..."
if command -v nc &>/dev/null; then
    echo "Netcat já está disponível no sistema."
    log_message "Netcat já está disponível no sistema."
elif pkg install -y netcat &>/dev/null || pkg install -y nmap-ncat &>/dev/null; then
    if command -v nc &>/dev/null || command -v ncat &>/dev/null; then
        echo "Netcat ou alternativa instalada com sucesso."
        log_message "Netcat ou alternativa instalada com sucesso."
    else
        echo "Erro: Netcat ou alternativas não estão disponíveis após a instalação."
        log_message "Erro: Netcat ou alternativas não estão disponíveis após a instalação."
        exit 1
    fi
else
    echo "Erro ao instalar Netcat ou alternativas."
    log_message "Erro ao instalar Netcat ou alternativas."
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
echo "Configurando permissões no Termux..."
log_message "Configurando permissões no Termux..."
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
./wuzapi &
WUZAPI_PID=$!

# Dar tempo para o servidor inicializar
sleep 5

# Verificar se o servidor está ativo com tentativas
SERVER_HOST="0.0.0.0"
SERVER_PORT="8080"
MAX_ATTEMPTS=5
attempt=1

echo "Verificando se o servidor está ativo em $SERVER_HOST:$SERVER_PORT..."
log_message "Verificando se o servidor está ativo em $SERVER_HOST:$SERVER_PORT..."

while ! nc -z "$SERVER_HOST" "$SERVER_PORT" &>/dev/null; do
    if [ $attempt -ge $MAX_ATTEMPTS ]; then
        echo "Erro: O servidor não está ativo em $SERVER_HOST:$SERVER_PORT após $attempt tentativas."
        log_message "Erro: O servidor não está ativo em $SERVER_HOST:$SERVER_PORT após $attempt tentativas."
        kill $WUZAPI_PID &>/dev/null
        exit 1
    fi

    echo "Tentativa $attempt de $MAX_ATTEMPTS falhou. Tentando novamente em 5 segundos..."
    log_message "Tentativa $attempt de $MAX_ATTEMPTS falhou. Tentando novamente em 5 segundos..."
    attempt=$((attempt + 1))
    sleep 5
done

echo "Servidor está ativo em $SERVER_HOST:$SERVER_PORT."
log_message "Servidor está ativo em $SERVER_HOST:$SERVER_PORT."

# Mensagem final de sucesso
echo "##### PROCESSO FINALIZADO COM SUCESSO #####"
log_message "##### PROCESSO FINALIZADO COM SUCESSO #####"
