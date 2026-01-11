from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def hello():
    return {'message':'This is your home page Welcom hasnain'}