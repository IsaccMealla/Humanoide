from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/cinta", tags=["Cinta Transportadora"])

# modelo de datos de la cinta
class CintaState(BaseModel):
    is_running: bool = False
    manual_override: bool = False
    sensor_ir_triggered: bool = False
    sensor_ultra_triggered: bool = False
    last_event: str = "Sistema en espera"

#estado en memoria
current_state = CintaState()

@router.get("/status")
def get_status():
    return current_state

@router.post("/update")
def update_status(state: CintaState):
    global current_state
    current_state = state
    return {"message": "Estado actualizado correctamente"}

class ControlCommand(BaseModel):
    action: str

@router.post("/control")
def control_cinta(command: ControlCommand):
    global current_state
    if command.action == "start":
        current_state.manual_override = True
        current_state.is_running = True
        current_state.last_event = "Encendido Manual activado"
    elif command.action == "stop":
        current_state.manual_override = True
        current_state.is_running = False
        current_state.last_event = "Apagado Manual activado"
    elif command.action == "auto":
        current_state.manual_override = False
        current_state.last_event = "Modo Automático (Sensores)"
    return current_state