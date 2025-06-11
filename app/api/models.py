from pydantic import BaseModel
from typing import Optional, Dict

class ServerParams(BaseModel):
    cps: Optional[bool] = False
    port: Optional[int] = 5202
    length: Optional[str] = "1k"
    csv_stats: Optional[bool] = True

class ClientParams(BaseModel):
    cps: Optional[str] = None
    port: Optional[int] = 5202
    length: Optional[str] = "1k"
    time: Optional[int] = 60
    csv_stats: Optional[bool] = True
    bitrate: Optional[str] = None
    parallel: Optional[int] = 1
    reverse: bool = False
    bidi: bool = False
    interval: Optional[int] = None

class ServerRequest(BaseModel):
    params: ServerParams

class ClientRequest(BaseModel):
    test_id: str
    server_ip: str
    params: ClientParams

class TestResponse(BaseModel):
    test_id: str
    status: str
    message: str
    server_pid: Optional[int] = None
    client_pid: Optional[int] = None
