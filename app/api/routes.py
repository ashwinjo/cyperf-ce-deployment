from fastapi import APIRouter, HTTPException
from app.api.models import ServerRequest, ClientRequest, TestResponse
from app.services.cyperf_service import CyperfService
import uuid

router = APIRouter()
cyperf_service = CyperfService()

@router.post("/server", response_model=TestResponse)
async def start_server(request: ServerRequest):
    test_id = str(uuid.uuid4())
    try:
        result = cyperf_service.start_server(test_id, request.params.dict())
        return TestResponse(
            test_id=test_id,
            server_pid=result["server_pid"],
            status="SERVER_RUNNING",
            message="Cyperf server started. Use test_id for all related operations."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/client", response_model=TestResponse)
async def start_client(request: ClientRequest):
    try:
        result = cyperf_service.start_client(
            request.test_id,
            request.server_ip,
            request.params.dict()
        )
        return TestResponse(
            test_id=request.test_id,
            client_pid=result["client_pid"],
            status="CLIENT_RUNNING",
            message="Cyperf client started and linked to server."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/test/{test_id}", response_model=TestResponse)
async def stop_test(test_id: str):
    try:
        result = cyperf_service.stop_test(test_id)
        return TestResponse(
            test_id=test_id,
            status="STOPPED",
            message=f"Stop signal sent to server (PID: {result.get('server_pid')}) and client (PID: {result.get('client_pid')})."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/server/stats/{test_id}")
async def get_server_stats(test_id: str):
    try:
        stats = cyperf_service.get_server_stats(test_id)
        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/client/stats/{test_id}")
async def get_client_stats(test_id: str):
    try:
        stats = cyperf_service.get_client_stats(test_id)
        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
