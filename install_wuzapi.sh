#!/data/data/com.termux/files/usr/bin/bash
echo "##### ESTE PROCESSO TARDARÁ ENTRE 15 A 20 MINUTOS #####"

# Instalar Git e Go
echo "Instalando Git e Go..."
pkg install -y git golang &>/dev/null
echo "Git e Go foram instalados com sucesso."

# Clonar o repositório tasker-wuzapi
echo "Clonando o repositório tasker-wuzapi..."
git clone https://github.com/Andredye28/tasker-wuzapi &>/dev/null
echo "Repositório clonado com sucesso."

# Navegar até o diretório do projeto
cd tasker-wuzapi

# Compilar o binário do WuzAPI
echo "Compilando o binário..."
go build . &>/dev/null

# Verificar se o binário foi compilado com sucesso
if [ -f "./wuzapi" ]; then
    echo "WuzAPI foi compilado com sucesso no Termux."

    # Dar permissões de execução ao binário e ao script de inicialização
    chmod +x wuzapi
    chmod +x start_wuzapi.sh

    echo "Permissões de execução atribuídas ao WuzAPI."
else
    echo "Erro ao compilar o WuzAPI."
    exit 1
fi

# Concedendo permissão para aplicativos externos no Termux
mkdir -p ~/.termux && echo "allow-external-apps=true" > ~/.termux/termux.properties
termux-reload-settings
echo "Permissão para aplicativos externos configurada."

# Adicionando a reconfiguração automática de permissão no .profile e .bashrc
for file in ~/.profile ~/.bashrc; do
    if ! grep -q "allow-external-apps=true" "$file"; then
        echo -e "\n# Configuração automática para permitir aplicativos externos no Termux após reinício" >> "$file"
        echo "mkdir -p ~/.termux && echo 'allow-external-apps=true' > ~/.termux/termux.properties && termux-reload-settings" >> "$file"
        echo "Configuração para reativação automática adicionada ao $file"
    else
        echo "Configuração para reativação automática já existente no $file"
    fi
done

# Executar WuzAPI
echo "Executando WuzAPI..."
./wuzapi
