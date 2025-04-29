from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import openai
import logging
import config

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = FastAPI()

# Add CORS middleware with more permissive settings
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

class Message(BaseModel):
    user_input: str

# Read the knowledge base file
with open("files/coded_info.txt", "r") as f:
    knowledge_base = f.read()

system_prompt = f"""You are a helpful assistant for CodEd, an educational platform. 
You have access to the following information about the platform:

{knowledge_base}

Use this information to answer user questions accurately and helpfully. 
If you don't know the answer based on the provided information, say so.
"""

@app.post("/chat")
async def chat(message: Message):
    try:
        logger.info(f"Received message: {message.user_input}")
        
        if not openai.api_key:

            logger.error("OpenAI API key not found")
            raise HTTPException(status_code=500, detail="OpenAI API key not found")
            
        # Create the chat completion
        logger.info("Creating chat completion...")
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": message.user_input}
            ],
            temperature=0.7,
            max_tokens=500
        )

        # Extract the assistant's response
        assistant_response = response.choices[0].message.content
        logger.info(f"Assistant response: {assistant_response}")
        return {"reply": assistant_response}

    except Exception as e:
        logger.error(f"Error in chat endpoint: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    # Run on all interfaces (0.0.0.0) and port 8000
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        reload=True,  # Enable auto-reload for development
        log_level="debug"  # Enable debug logging
    )
