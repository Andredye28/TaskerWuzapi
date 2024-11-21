#!/data/data/com.termux/files/usr/bin/bash

# Caminho do arquivo de log
LOG_FILE="/storage/emulated/0/Tasker/termux/TASKER-WUZAPI/logs/install.log"

# Variável de controle para o log
LOGGING_ENABLED=1

# Verificar e criar o arquivo de log
if [ ! -f "$LOG_FILE" ]; then
    mkdir -p "$(dirname "$LOG_FILE")" || { echo "Erro ao criar o diretório de logs."; exit 1; }
    touch "$LOG_FILE" || { echo "Erro ao criar o arquivo de log."; exit 1; }
else
    > "$LOG_FILE"  # Limpar o conteúdo do arquivo existente
fi

# Função para registrar mensagens no log
log_message() {
    if [ "$LOGGING_ENABLED" -eq 1 ]; then
        echo -e "\033[1;33m$1\033[0m" >> "$LOG_FILE"
    fi
}

# Função para monitorar a saída
monitor_output() {
    while IFS= read -r line; do
    echo -e "\033[1;33m$line\033[0m"  # Mostrar a saída no terminal
        log_message "$line"  # Registrar no log se habilitado

        # Parar logs se a mensagem específica for encontrada
        if [[ "$line" == *"QR pairing ok! host=0.0.0.0 role=wuzapi"* ]]; then
            sleep 5  # Aguardar 5 segundos
            log_message "CONEXÃO COM SERVIDOR BEM SUCEDIDA"  # Adiciona o log após o atraso
            LOGGING_ENABLED=0  # Interrompe os logs
            echo -e "\033[1;33mLogs interrompidos após detectar a mensagem: $line\033[0m"
        fi
    done
}

# Redirecionar para o diretório home do Termux
cd /data/data/com.termux/files/home
 "echo -e "\033[1;33m:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo -e "                                          "
echo -e "                 🚀  INICIANDO PROCESSO DE CONFIGURACAO 🚀
                         DO TASKER-WUZAPI-CHATBOT
       "
echo -e "                                          "
echo -e "                 👋   BEM-VINDO AO TASKER-WUZAPI-CHATBOT   👋          "
echo -e "                                                "
echo -e "                                          "
echo -e "                    A INSTALACAO PODE LEVAR ATE 10 MINUTOS
                    POR FAVOR AGUARDE O PROCESSO FINALIZAR"
echo -e "
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\033[0m""
log_message ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

                 🚀  INICIANDO PROCESSO DE CONFIGURACAO 🚀
                         DO TASKER-WUZAPI-CHATBOT
       

                 👋   BEM-VINDO AO TASKER-WUZAPI-CHATBOT   👋          


                    A INSTALACAO PODE LEVAR ATE 10 MINUTOS
                    POR FAVOR AGUARDE O PROCESSO FINALIZAR

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
"


# Remover diretório existente se já estiver presente
if [ -d "tasker_wuzapi" ]; then
    rm -rf tasker_wuzapi
    echo -e "\033[1;33mDIRETÓRIO ANTERIOR DO TASKER-WUZAPI REMOVIDO PARA NOVA CONFIGURAÇÃO\033[0m"

    log_message "33mDIRETÓRIO ANTERIOR DO TASKER-WUZAPI REMOVIDO PARA NOVA CONFIGURAÇÃO"
fi

# Instalar Git e Go
echo -e "\033[1;33mINSTALANDO GIT E GO...\033[0m"

log_message "33mINSTALANDO GIT E GO..."
pkg install -y git golang 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

# Clonar o repositório tasker-wuzapi
echo -e "\033[1;33mCLONANDO O REPOSITÓRIO TASKER-WUZAPI...\033[0m"
log_message "CLONANDO O REPOSITÓRIO TASKER-WUZAPI..."
git clone https://github.com/Andredye28/tasker_wuzapi 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

# Navegar até o diretório do projeto
echo -e "\033[1;33mACESSANDO O DIRETÓRIO DO PROJETO...\033[0m"
log_message "ACESSANDO O DIRETÓRIO DO PROJETO..."
cd tasker_wuzapi || { 
    echo -e "\033[1;33mERRO AO ACESSAR O DIRETÓRIO DO PROJETO\033[0m"; 
    log_message "ERRO AO ACESSAR O DIRETÓRIO DO PROJETO"; 
    exit 1; 
}

# Compilar o binário do WuzAPI
echo -e "\033[1;33mCOMPILANDO O BINÁRIO...\033[0m"
log_message "COMPILANDO O BINÁRIO..."
go build . 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

# Dar permissões de execução ao binário e ao script de inicialização
chmod +x wuzapi
if [ -f "./start_wuzapi.sh" ]; then
    chmod +x start_wuzapi.sh
fi

# Conceder permissões para aplicativos externos no Termux
echo -e "\033[1;33mCONFIGURANDO PERMISSÕES PARA APLICATIVOS EXTERNOS\033[0m"
log_message "CONFIGURANDO PERMISSÕES PARA APLICATIVOS EXTERNOS..."
mkdir -p ~/.termux && echo "allow-external-apps=true" >> ~/.termux/termux.properties
termux-reload-settings 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

# Executar WuzAPI
echo -e "\033[1;33mEXECUTANDO SERVIDOR WUZAPI...\033[0m"
log_message "EXECUTANDO SERVIDOR WUZAPI..."
./wuzapi 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

# Mensagem final
echo -e "\033[1;33mCONEXÃO COM SERVIDOR BEM SUCEDIDA\033[0m"
log_message "CONEXÃO COM SERVIDOR BEM SUCEDIDA"
