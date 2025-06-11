from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    SERVER_IP: str = "44.222.247.193"
    CLIENT_IP: str = "35.94.178.35"
    SSH_USERNAME: str = "ubuntu"
    SSH_KEY_PATH: str = "/Users/ashwjosh/vibecode.pem"

    class Config:
        env_file = ".env"

settings = Settings()
