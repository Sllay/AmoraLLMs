from huggingface_hub import hf_hub_download
import os

MODEL_REPO = "TheBloke/Qwen2.5-7B-Instruct-GGUF"
MODEL_FILE = "qwen2.5-7b-instruct.Q4_K_M.gguf"

os.makedirs("models", exist_ok=True)

print("⬇️ Baixando modelo...")

hf_hub_download(
    repo_id=MODEL_REPO,
    filename=MODEL_FILE,
    local_dir="models",
    local_dir_use_symlinks=False
)

print("✅ Modelo pronto")
