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

# Redirecionar para o diretório home do Termux
cd /data/data/com.termux/files/home

echo "##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####"
log_message "##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####"
echo "##### ESTE PROCESSO PODE LEVAR ENTRE 15 A 20 MINUTOS #####"
log_message "##### ESTE PROCESSO PODE LEVAR ENTRE 15 A 20 MINUTOS #####"

# Remover diretório existente se já estiver presente
if [ -d "tasker_wuzapi" ]; then
    rm -rf tasker_wuzapi
    echo "Diretório anterior do WuzAPI removido."
    log_message "Diretório anterior do WuzAPI removido."
fi

# Instalar Git e Go
echo "Instalando Git e Go..."
log_message "Instalando Git e Go..."
pkg install -y git golang 2>&1 | tee -a "$LOG_FILE"

# Clonar o repositório tasker-wuzapi
echo "Clonando o repositório tasker-wuzapi..."
log_message "Clonando o repositório tasker-wuzapi..."
git clone https://github.com/Andredye28/tasker_wuzapi 2>&1 | tee -a "$LOG_FILE"

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
go build . 2>&1 | tee -a "$LOG_FILE"

# Dar permissões de execução ao binário e ao script de inicialização
chmod +x wuzapi
if [ -f "./start_wuzapi.sh" ]; then
    chmod +x start_wuzapi.sh
fi

# Conceder permissões para aplicativos externos no Termux
echo "Configurando permissões para aplicativos externos no Termux..."
log_message "Configurando permissões para aplicativos externos no Termux..."
mkdir -p ~/.termux && echo "allow-external-apps=true" >> ~/.termux/termux.properties
termux-reload-settings 2>&1 | tee -a "$LOG_FILE"

# Executar WuzAPI
echo "Executando WuzAPI..."
log_message "Executando WuzAPI..."
./wuzapi 2>&1 | tee -a "$LOG_FILE"
