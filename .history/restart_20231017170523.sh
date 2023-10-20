#!/bin/bash

# FILEPATH: /home/anderson/academico/aalt/codelabs/restart.sh

# Verifica se o servidor está em execução e, se estiver, interrompe-o
if pgrep -x "claat" > /dev/null
then
    echo "Servidor claat em execução. Interrompendo..."
    pkill -f "claat serve"
fi

# Exporta o conteúdo do arquivo .md passado como parâmetro usando o claat
echo "Exportando conteúdo do arquivo $1..."
claat export $1

# Inicia o servidor para abrir o codelab gerado
echo "Iniciando servidor claat..."
claat serve
