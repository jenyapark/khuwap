from typing import Any,Optional
from fastapi.responses import JSONResponse

def success_response(
    data: Optional[Any] = None,
    message: str = "요청이 성공적으로 처리되었습니다.",
    status_code: int = 200
) -> JSONResponse:
    return JSONResponse(
        status_code = status_code,
        content={
            "success" : True,
            "message" : message,
            "data" : data
        }
    )

       
def error_response(
    message: str = "요청 처리 중 오류가 발생했습니다.",
    status_code: int = 400,
    data: Optional[Any] = None
) -> JSONResponse:
    return JSONResponse(
        status_code = status_code,
        content={
            "success": False,
            "message" : message,
            "data": data,
        },
    )