#!/data/data/com.termux/files/usr/bin/bash
echo "##### INICIANDO O PROCESSO DE CONFIGURAÇÃO DO WUZAPI #####"
echo "##### ESTE PROCESSO PODE LEVAR ENTRE 15 A 20 MINUTOS #####"

# Instalar Git e Go
echo "Instalando Git e Go..."
if pkg install -y git golang &>/dev/null; then
    echo "Git e Go foram instalados com sucesso."
else
    echo "Erro ao instalar Git e Go. Verifique sua conexão ou tente novamente."
    exit 1
fi

# Clonar o repositório tasker-wuzapi
echo "Clonando o repositório tasker-wuzapi..."
if git clone https://github.com/Andredye28/tasker_wuzapi &>/dev/null; then
    echo "Repositório clonado com sucesso."
else
    echo "Erro ao clonar o repositório. Verifique o link ou sua conexão."
    exit 1
fi

# Navegar até o diretório do projeto
cd tasker_wuzapi || { echo "Erro ao acessar o diretório do projeto."; exit 1; }

# Verificar se o Go está configurado corretamente
if ! command -v go &>/dev/null; then
    echo "Erro: Go não está configurado corretamente. Verifique sua instalação."
    exit 1
fi

# Compilar o binário do WuzAPI
echo "Compilando o binário..."
if go build . &>/dev/null; then
    echo "WuzAPI foi compilado com sucesso no Termux."
else
    echo "Erro ao compilar o WuzAPI. Verifique o código-fonte e as dependências."
    exit 1
fi

# Dar permissões de execução ao binário e ao script de inicialização
chmod +x wuzapi
if [ -f "./start_wuzapi.sh" ]; then
    chmod +x start_wuzapi.sh
    echo "Permissões de execução atribuídas ao WuzAPI e ao script de inicialização."
else
    echo "Aviso: O script de inicialização 'start_wuzapi.sh' não foi encontrado."
fi

# Conceder permissões para aplicativos externos no Termux
echo "Configurando permissões para aplicativos externos no Termux..."
mkdir -p ~/.termux && echo "allow-external-apps=true" >> ~/.termux/termux.properties
if termux-reload-settings; then
    echo "Permissões configuradas e recarregadas com sucesso."
else
    echo "Erro ao recarregar as configurações do Termux."
    exit 1
fi

# Executar WuzAPI
echo "Executando WuzAPI..."
if ./wuzapi; then
    echo "WuzAPI está rodando com sucesso."
else
    echo "Erro ao executar o WuzAPI. Verifique o binário ou as permissões."
    exit 1
fi

echo "##### PROCESSO FINALIZADO COM SUCESSO #####"
