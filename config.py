# OpenAI API Key for the chatbot
import os
from dotenv import load_dotenv

load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")  # ✅ Good

