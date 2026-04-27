#!/bin/bash

mkdir -p models

if [ ! -f models/qwen.gguf ]; then
  echo "📥 Baixando modelo..."

  wget -O models/qwen.gguf \
  https://huggingface.co/TheBloke/Qwen2.5-7B-Instruct-GGUF/resolve/main/qwen2.5-7b-instruct.Q4_K_M.gguf
fi

echo "🚀 Iniciando servidor..."
uvicorn server.main:app --host 0.0.0.0 --port $PORT
