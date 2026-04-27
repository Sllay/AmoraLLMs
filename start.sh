#!/bin/bash

echo "🚀 Baixando modelo se necessário..."
python download_model.py

echo "🔥 Iniciando servidor..."
uvicorn server.main:app --host 0.0.0.0 --port 10000
