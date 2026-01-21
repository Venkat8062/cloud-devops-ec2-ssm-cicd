from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()


class CalculationRequest(BaseModel):
    a: float
    b: float
    operation: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/calculate")
def calculate(req: CalculationRequest):
    if req.operation == "add":
        result = req.a + req.b
    elif req.operation == "subtract":
        result = req.a - req.b
    elif req.operation == "multiply":
        result = req.a * req.b
    elif req.operation == "divide":
        if req.b == 0:
            return {"error": "Division by zero"}
        result = req.a / req.b
    else:
        return {"error": "Invalid operation"}

    return {"result": result}
