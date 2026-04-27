from fastapi import FastAPI
from pydantic import BaseModel
from llama_cpp import Llama
import os

app = FastAPI()

MODEL_PATH = "models/model.gguf"

llm = None

class Request(BaseModel):
    text: str

def load_model():
    global llm
    if llm is None:
        llm = Llama(
            model_path=MODEL_PATH,
            n_ctx=2048,
            n_threads=4
        )

@app.post("/chat")
def chat(req: Request):
    load_model()

    output = llm(
        req.text,
        max_tokens=300,
        temperature=0.9,
        stop=["</s>"]
    )

    return {
        "reply": output["choices"][0]["text"]
    }
