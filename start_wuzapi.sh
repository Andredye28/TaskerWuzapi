#!/data/data/com.termux/files/usr/bin/bash

# Caminho do arquivo de log
LOG_FILE="/storage/emulated/0/Tasker/termux/TASKER-WUZAPI/logs/reconect.log"

# Verificar e criar o diretório de logs se não existir
mkdir -p "$(dirname "$LOG_FILE")"

# Definir permissões para o diretório de logs
chmod 755 "$(dirname "$LOG_FILE")"

# Limpar o conteúdo do arquivo de log (ou criá-lo se não existir)
> "$LOG_FILE"

# Adicionar permissões de escrita para o arquivo de log
chmod 666 "$LOG_FILE"

# Mudar para o diretório do script
cd tasker_wuzapi

# Executar o script wuzapi e redirecionar toda a saída para o arquivo de log
./wuzapi 2>&1 | tee "$LOG_FILE" || true
