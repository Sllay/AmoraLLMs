#!/bin/bash

set -e

echo "🚀 Iniciando AmoraLLM..."

mkdir -p models

MODEL_PATH="models/qwen.gguf"

# -----------------------------
# VALIDAR GGUF
# -----------------------------
validate_model() {
    if [ ! -f "$MODEL_PATH" ]; then
        return 1
    fi

    # verifica header GGUF
    if head -c 4 "$MODEL_PATH" | grep -q "GGUF"; then
        return 0
    else
        echo "❌ Arquivo não é GGUF válido"
        return 1
    fi
}

# -----------------------------
# DOWNLOAD QWEN 7B (split)
# -----------------------------
download_qwen() {
    echo "📥 Baixando Qwen 7B..."

    wget -O models/part1.gguf \
    https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF/resolve/main/qwen2.5-7b-instruct-q4_k_m-00001-of-00002.gguf

    wget -O models/part2.gguf \
    https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF/resolve/main/qwen2.5-7b-instruct-q4_k_m-00002-of-00002.gguf

    echo "🔧 Juntando partes..."
    cat models/part1.gguf models/part2.gguf > "$MODEL_PATH"

    rm -f models/part1.gguf models/part2.gguf
}

# -----------------------------
# FALLBACK (leve)
# -----------------------------
download_fallback() {
    echo "⚠️ Baixando modelo leve (TinyLlama)..."

    wget -O "$MODEL_PATH" \
    https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-GGUF/resolve/main/tinyllama-1.1b-chat.Q4_K_M.gguf
}

# -----------------------------
# FLOW
# -----------------------------

if validate_model; then
    echo "✅ Modelo já válido"
else
    echo "❌ Modelo não encontrado ou inválido"

    if download_qwen; then
        if validate_model; then
            echo "✅ Qwen pronto"
        else
            echo "❌ Qwen corrompido"
            download_fallback
        fi
    else
        echo "❌ Falha no download Qwen"
        download_fallback
    fi
fi

# valida final
if ! validate_model; then
    echo "💥 ERRO: nenhum modelo válido disponível"
    exit 1
fi

echo "🚀 Modelo OK, iniciando API..."

# IMPORTANTE: só inicia depois de tudo pronto
exec uvicorn server.main:app --host 0.0.0.0 --port $PORT