#!/data/data/com.termux/files/usr/bin/bash

# Caminho do arquivo de log
LOG_FILE="/storage/emulated/0/Tasker/termux/TASKER-WUZAPI/logs/install.log"

# Variável de controle para o log
LOGGING_ENABLED=1

# Verificar e criar o arquivo de log
if [ ! -f "$LOG_FILE" ]; then
    mkdir -p "$(dirname "$LOG_FILE")" || { echo -e "\033[33mErro ao criar o diretório de logs.\033[0m"; exit 1; }
    touch "$LOG_FILE" || { echo -e "\033[33mErro ao criar o arquivo de log.\033[0m"; exit 1; }
else
    > "$LOG_FILE"  # Limpar o conteúdo do arquivo existente
fi

# Função para registrar mensagens no log
log_message() {
    if [ "$LOGGING_ENABLED" -eq 1 ]; then
        echo "$1" | tr 'a-z' 'A-Z' >> "$LOG_FILE"
    fi
}

# Função para monitorar a saída
monitor_output() {
    while IFS= read -r line; do
        echo -e "\033[33m$line\033[0m"  # Mostrar a saída no terminal em amarelo
        log_message "$line"  # Registrar no log se habilitado

        # Parar logs se a mensagem específica for encontrada
        if [[ "$line" == *"QR pairing ok! host=0.0.0.0 role=wuzapi"* ]]; then
            sleep 2  # Aguardar 2 segundos
            log_message "CONEXÃO COM SERVIDOR ESTABELECIDO COM SUCESSO"  # Adiciona o log após o atraso
            LOGGING_ENABLED=0  # Interrompe os logs
            echo -e "\033[33mLogs interrompidos após detectar a mensagem: $line\033[0m"
        fi
    done
}

# Redirecionar para o diretório home do Termux
cd /data/data/com.termux/files/home

echo -e "\033[33m##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####\033[0m"
log_message "##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####"
echo -e "\033[33m##### ESTE PROCESSO PODE LEVAR ENTRE 15 A 20 MINUTOS #####\033[0m"
log_message "##### ESTE PROCESSO PODE LEVAR ENTRE 15 A 20 MINUTOS #####"

# Remover diretório existente se já estiver presente
if [ -d "tasker_wuzapi" ]; then
    rm -rf tasker_wuzapi
    echo -e "\033[33mDiretório anterior do WuzAPI removido.\033[0m"
    log_message "Diretório anterior do WuzAPI removido."
fi

# Instalar Git e Go
echo -e "\033[33mInstalando Git e Go...\033[0m"
log_message "Instalando Git e Go..."
pkg install -y git golang 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

# Clonar o repositório tasker-wuzapi
echo -e "\033[33mClonando o repositório tasker-wuzapi...\033[0m"
log_message "Clonando o repositório tasker-wuzapi..."
git clone https://github.com/Andredye28/tasker_wuzapi 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

# Navegar até o diretório do projeto
echo -e "\033[33mAcessando o diretório do projeto...\033[0m"
log_message "Acessando o diretório do projeto..."
cd tasker_wuzapi || { 
    echo -e "\033[33mErro ao acessar o diretório do projeto.\033[0m"; 
    log_message "Erro ao acessar o diretório do projeto."; 
    exit 1; 
}

# Compilar o binário do WuzAPI
echo -e "\033[33mCompilando o binário...\033[0m"
log_message "Compilando o binário..."
go build . 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

# Dar permissões de execução ao binário e ao script de inicialização
chmod +x wuzapi
if [ -f "./start_wuzapi.sh" ]; then
    chmod +x start_wuzapi.sh
fi

# Conceder permissões para aplicativos externos no Termux
echo -e "\033[33mConfigurando permissões para aplicativos externos no Termux...\033[0m"
log_message "Configurando permissões para aplicativos externos no Termux..."
mkdir -p ~/.termux && echo "allow-external-apps=true" >> ~/.termux/termux.properties
termux-reload-settings 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

# Executar WuzAPI
echo -e "\033[33mExecutando WuzAPI...\033[0m"
log_message "Executando WuzAPI..."
./wuzapi 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done
