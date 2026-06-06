import io
from uuid import uuid4

from fastapi import APIRouter, HTTPException, UploadFile, File
from pydantic import BaseModel
from Agent.chat_core import (
    detect_robot_action,
    get_barista_chatbot_response,
    get_next_prompt,
    get_welcome_message,
    is_continue_intent,
    is_exit_intent,
    is_pause_intent,
)
from gtts import gTTS
from fastapi.responses import StreamingResponse

router = APIRouter()
SESSIONS: dict[str, dict] = {}

class ChatRequest(BaseModel):
    mensaje: str
    rol: str = "cliente"
    session_id: str | None = None

class ChatResponse(BaseModel):
    respuesta: str
    rol: str
    session_id: str
    action: str = "none"
    robot_state: str = "idle"
    solicitar_siguiente_paso: bool = True


def _get_or_create_session(session_id: str | None) -> str:
    if session_id and session_id in SESSIONS:
        return session_id

    new_session_id = str(uuid4())
    SESSIONS[new_session_id] = {
        "last_action": "none",
        "active": True,
    }
    return new_session_id


@router.get("/welcome", response_model=ChatResponse)
async def welcome(rol: str = "cliente"):
    session_id = _get_or_create_session(None)
    return ChatResponse(
        respuesta=get_welcome_message(),
        rol=rol,
        session_id=session_id,
        action="welcome",
        robot_state="idle",
        solicitar_siguiente_paso=True,
    )

@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    if not request.mensaje:
        raise HTTPException(status_code=400, detail="El campo 'mensaje' es requerido.")

    session_id = _get_or_create_session(request.session_id)
    session = SESSIONS[session_id]

    if not session.get("active", True):
        session["active"] = True

    try:
        message = request.mensaje.strip()

        if is_exit_intent(message):
            session["active"] = False
            return ChatResponse(
                respuesta="Perfecto, detengo la interaccion por ahora. Si deseas volver, solo dime hola.",
                rol=request.rol,
                session_id=session_id,
                action="end_session",
                robot_state="stopped",
                solicitar_siguiente_paso=False,
            )

        if is_pause_intent(message):
            return ChatResponse(
                respuesta="Entendido. Quedo atento. Cuando quieras, dime continuar o pide una bebida.",
                rol=request.rol,
                session_id=session_id,
                action="pause",
                robot_state="idle",
                solicitar_siguiente_paso=True,
            )

        if is_continue_intent(message):
            return ChatResponse(
                respuesta="Excelente, continuamos. Dime que comando quieres para el robot barista.",
                rol=request.rol,
                session_id=session_id,
                action="continue",
                robot_state="idle",
                solicitar_siguiente_paso=True,
            )

        robot_action = detect_robot_action(message)
        if robot_action:
            session["last_action"] = robot_action["action"]
            return ChatResponse(
                respuesta=f"{robot_action['response']} {get_next_prompt()}",
                rol=request.rol,
                session_id=session_id,
                action=robot_action["action"],
                robot_state="completed",
                solicitar_siguiente_paso=True,
            )

        respuesta = get_barista_chatbot_response(message, request.rol)
        return ChatResponse(
            respuesta=f"{respuesta} {get_next_prompt()}",
            rol=request.rol,
            session_id=session_id,
            action="qa",
            robot_state="idle",
            solicitar_siguiente_paso=True,
        )
    except Exception:
        return ChatResponse(
            respuesta="Lo siento, en este momento no puedo procesar tu consulta. Soy un barista en entrenamiento.",
            rol=request.rol,
            session_id=session_id,
            action="error",
            robot_state="idle",
            solicitar_siguiente_paso=True,
        )

@router.post("/voice-chat")
async def voice_chat(file: UploadFile = File(...), rol: str = "cliente"):
    """
    Recibe un archivo de audio, lo procesa (opcional si el front ya manda texto),
    genera la respuesta del agente y devuelve el audio de la respuesta.
    """
    # En esta versión simplificada, asumimos que el front envía el texto 
    # o que procesaremos el audio aquí. Por simplicidad para el "estilo llamada",
    # vamos a permitir enviar texto y recibir audio, o recibir audio -> texto -> audio.
    
    # Simulación de Voz a Texto (STT) -> Chat -> Texto a Voz (TTS)
    # Por ahora, implementaremos la parte de TTS para que sea funcional el "hablar".
    
    # Nota: Para un STT real necesitarías procesar 'file' con SpeechRecognition o Whisper.
    # Como el usuario pidió "estilo llamada", el front puede mandar el audio.
    
    # 1. (Opcional) STT - Convertir audio a texto
    # user_text = stt_process(file)
    
    # Por ahora asumimos una interacción de prueba si no hay texto:
    user_text = "Hola barista, recomiéndame algo." 
    
    respuesta_texto = get_barista_chatbot_response(user_text, rol)
    
    # 2. TTS - Convertir respuesta a audio
    tts = gTTS(text=respuesta_texto, lang='es')
    audio_fp = io.BytesIO()
    tts.write_to_fp(audio_fp)
    audio_fp.seek(0)
    
    return StreamingResponse(audio_fp, media_type="audio/mpeg")

@router.get("/tts")
async def get_tts(text: str):
    """
    Convierte texto a audio directamente.
    """
    if not text:
        raise HTTPException(status_code=400, detail="Texto requerido")
    
    tts = gTTS(text=text, lang='es')
    audio_fp = io.BytesIO()
    tts.write_to_fp(audio_fp)
    audio_fp.seek(0)
    
    return StreamingResponse(audio_fp, media_type="audio/mpeg")
