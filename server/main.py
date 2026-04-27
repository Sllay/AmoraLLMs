from fastapi import FastAPI
from pydantic import BaseModel
from llama_cpp import Llama

app = FastAPI()

llm = Llama(
    model_path="models/qwen.gguf",
    n_ctx=2048,
    n_threads=4
)

class ChatRequest(BaseModel):
    message: str

@app.post("/chat")
def chat(req: ChatRequest):
    prompt = f"""### Usuário:
{req.message}

### Amora:
"""

    output = llm(
        prompt,
        max_tokens=300,
        temperature=0.8,
        stop=["###"]
    )

    return {
        "reply": output["choices"][0]["text"].strip()
    }