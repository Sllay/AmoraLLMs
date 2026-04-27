#!/bin/bash

set -e

echo " Iniciando AmoraLLM..."

mkdir -p models

MODEL_PATH="models/qwen.gguf"

# -----------------------------
# FUN��O: validar GGUF
# -----------------------------
validate_model() {
    if [ ! -f "$MODEL_PATH" ]; then
        return 1
    fi

    # verifica se � arquivo GGUF v�lido
    if head -c 4 "$MODEL_PATH" | grep -q "GGUF"; then
        return 0
    else
        return 1
    fi
}

# -----------------------------
# FUN��O: baixar modelo grande (7B split)
# -----------------------------
download_qwen_7b() {
    echo " Baixando Qwen 7B (split)..."

    wget -O models/part1.gguf \
    https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF/resolve/main/qwen2.5-7b-instruct-q4_k_m-00001-of-00002.gguf

    wget -O models/part2.gguf \
    https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF/resolve/main/qwen2.5-7b-instruct-q4_k_m-00002-of-00002.gguf

    echo " Fazendo merge..."
    cat models/part1.gguf models/part2.gguf > "$MODEL_PATH"

    rm models/part1.gguf models/part2.gguf
}

# -----------------------------
# FUN��O: fallback modelo leve
# -----------------------------
download_fallback() {
    echo " Usando modelo fallback (1.5B)..."

    wget -O "$MODEL_PATH" \
    https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-GGUF/resolve/main/tinyllama-1.1b-chat.Q4_K_M.gguf
}

# -----------------------------
# MAIN FLOW
# -----------------------------

if validate_model; then
    echo " Modelo j� existe e � v�lido"
else
    echo " Modelo inv�lido ou inexistente"

    # tenta baixar 7B
    if download_qwen_7b; then
        if validate_model; then
            echo " Qwen 7B pronto"
        else
            echo " Falha no modelo 7B"
            download_fallback
        fi
    else
        echo " Erro no download 7B"
        download_fallback
    fi
fi

# valida final
if ! validate_model; then
    echo " ERRO CR�TICO: nenhum modelo v�lido"
    exit 1
fi

echo " Iniciando servidor..."
uvicorn server.main:app --host 0.0.0.0 --port $PORT