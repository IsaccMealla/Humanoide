import os
import re
import importlib
from typing import Optional
from dotenv import load_dotenv
from langchain_google_genai import ChatGoogleGenerativeAI, GoogleGenerativeAIEmbeddings
from langchain_chroma import Chroma
from langchain_core.prompts import ChatPromptTemplate

def _load_langchain_factories():
    """Carga factories compatibles con LangChain 0.x y 1.x."""
    try:
        chains_module = importlib.import_module('langchain.chains')
        combine_module = importlib.import_module(
            'langchain.chains.combine_documents'
        )
    except ModuleNotFoundError:
        chains_module = importlib.import_module('langchain_classic.chains')
        combine_module = importlib.import_module(
            'langchain_classic.chains.combine_documents'
        )

    return (
        getattr(chains_module, 'create_retrieval_chain'),
        getattr(combine_module, 'create_stuff_documents_chain'),
    )

load_dotenv()

DB_DIR = os.path.join(os.path.dirname(__file__), 'vectorad_db')

ROLE_POLICY = {
    'barista': {
        'label': 'Barista',
        'summary': (
            'Encargado de preparar bebidas, gestionar inventario de café y asegurar la calidad.'
        ),
        'limits': (
            'No puede modificar precios finales ni acceder a datos financieros sensibles.'
        ),
    },
    'cliente': {
        'label': 'Cliente',
        'summary': 'Persona que disfruta de nuestras bebidas y busca recomendaciones.',
        'limits': 'No puede acceder a procesos internos de preparación técnica detallada ni inventarios.',
    },
}

ROLE_HINT_KEYWORDS = {
    'barista',
    'rol',
    'roles',
    'permiso',
    'permisos',
    'cliente',
}

CATALOG_KEYWORDS = {
    'menu', 'café', 'cafe', 'bebida', 'bebidas', 'precios'
}

SENSITIVE_KEYWORDS = {
        'password', 'contrasena', 'contraseña', 'token', 'api key', 'apikey', 'secret', 'jwt',
    'supabase', 'sql', 'query', 'database', 'base de datos', 'credenciales', 'access key',
    'private key', 'tabla usuarios', 'tabla user', 'correo proveedor', 'email proveedor',
    'telefono proveedor', 'teléfono proveedor', 'contacto proveedor'
}

EXIT_KEYWORDS = {'salir', 'cerrar', 'terminar', 'finalizar', 'adios', 'adiós'}
PAUSE_KEYWORDS = {'por el momento no', 'ahora no', 'no por ahora'}
CONTINUE_KEYWORDS = {'continuar', 'seguir', 'otra', 'otro comando'}

ROBOT_COMMANDS = (
    {
        'action': 'preparar_espresso',
        'keywords': ('espresso', 'expreso', 'corto'),
        'response': 'Listo, el robot ha iniciado la preparacion de un Espresso.'
    },
    {
        'action': 'preparar_cappuccino',
        'keywords': ('cappuccino', 'capuchino'),
        'response': 'Perfecto, el robot esta preparando un Cappuccino.'
    },
    {
        'action': 'preparar_latte',
        'keywords': ('latte', 'cafe con leche'),
        'response': 'Entendido, el robot esta preparando un Latte suave.'
    },
    {
        'action': 'limpiar_robot',
        'keywords': ('limpiar', 'limpieza', 'enjuagar'),
        'response': 'Hecho, el robot inicio la rutina de limpieza.'
    },
    {
        'action': 'estado_robot',
        'keywords': ('estado', 'status', 'como va', 'como esta el robot'),
        'response': 'El robot esta operativo y listo para ejecutar pedidos.'
    },
)

def _normalize_text(value: str) -> str:
    text = value.lower().strip()
    replacements = {
        'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ñ': 'n'
    }
    for original, replacement in replacements.items():
        text = text.replace(original, replacement)
    return text

def _is_sensitive_request(user_query: str) -> bool:
    normalized = _normalize_text(user_query)
    return any(keyword in normalized for keyword in SENSITIVE_KEYWORDS)

def _looks_like_role_policy_request(user_query: str) -> bool:
    normalized = _normalize_text(user_query)
    return any(keyword in normalized for keyword in ROLE_HINT_KEYWORDS)

def _role_policy_context() -> str:
    lines = ['POLITICA DE ROLES DEL SISTEMA:']
    for role_key in ('barista', 'cliente'):
        policy = ROLE_POLICY[role_key]
        lines.append(f"- {policy['label']}: {policy['summary']} {policy['limits']}")
    return '\n'.join(lines)

def _safe_catalog_context() -> str:
    # TODO: Implementar consulta a Supabase para obtener el menú real
    return "Menú disponible: Espresso, Americano, Cappuccino, Latte, Flat White, Mocha."

def _sanitize_response(text: str) -> str:
    sanitized = text
    # Ocultar posibles correos o tokens largos que accidentalmente aparezcan.
    sanitized = re.sub(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}', '[correo-protegido]', sanitized)
    sanitized = re.sub(r'(?i)(token|apikey|api key|password|secret)\\s*[:=]\\s*\\S+', r'\\1: [protegido]', sanitized)
    return sanitized

def get_welcome_message() -> str:
    return (
        'Hola, te doy la bienvenida a AppBarista. '
        'Soy tu chatbot barista y tambien puedo controlar el robot. '
        'Que quieres hacer hoy?'
    )

def get_next_prompt() -> str:
    return (
        '¿Que quieres hacer ahora? '
        'Puedes pedir otro comando, decir continuar, '
        'por el momento no, o salir.'
    )

def is_exit_intent(user_query: str) -> bool:
    normalized = _normalize_text(user_query)
    return any(word in normalized for word in EXIT_KEYWORDS)

def is_pause_intent(user_query: str) -> bool:
    normalized = _normalize_text(user_query)
    return any(word in normalized for word in PAUSE_KEYWORDS)

def is_continue_intent(user_query: str) -> bool:
    normalized = _normalize_text(user_query)
    return any(word in normalized for word in CONTINUE_KEYWORDS)

def detect_robot_action(user_query: str) -> Optional[dict]:
    normalized = _normalize_text(user_query)
    if not any(word in normalized for word in ('robot', 'prepara', 'hacer', 'haz', 'inicia', 'estado', 'limpia', 'cafe', 'cafe')):
        # Igual permitimos comandos directos de bebida sin mencionar "robot".
        pass

    for item in ROBOT_COMMANDS:
        if any(keyword in normalized for keyword in item['keywords']):
            return item
    return None

def _role_response_for_query(user_query: str, user_role: str) -> str:
    normalized = _normalize_text(user_query)
    default_policy = ROLE_POLICY.get(user_role, ROLE_POLICY['cliente'])

    if 'cliente' in normalized:
        selected = ROLE_POLICY['cliente']
    elif 'barista' in normalized:
        selected = ROLE_POLICY['barista']
    else:
        selected = default_policy

    return (
        f"Rol consultado: {selected['label']}. "
        f"Resumen: {selected['summary']} "
        f"Restricciones: {selected['limits']}"
    )

def get_barista_chatbot_response(user_query: str, user_role: str = 'cliente') -> str:
    if _is_sensitive_request(user_query):
        return (
            'Lo siento, no puedo proporcionar información técnica interna o datos privados. '
            '¿En qué puedo ayudarte con nuestro menú de café?'
        )

    if _looks_like_role_policy_request(user_query):
        return _role_response_for_query(user_query, user_role)

    normalized_query = _normalize_text(user_query)
    if any(keyword in normalized_query for keyword in CATALOG_KEYWORDS):
        return (
            'Claro. ' + _safe_catalog_context() +
            ' Si quieres, te recomiendo un Latte si buscas algo suave.'
        )

    if 'hola' in normalized_query or 'buenas' in normalized_query:
        return get_welcome_message()

    create_retrieval_chain, create_stuff_documents_chain = (
        _load_langchain_factories()
    )

    llm = ChatGoogleGenerativeAI(model="gemini-2.5-flash", temperature=0.7)
    embeddings = GoogleGenerativeAIEmbeddings(model="models/gemini-embedding-001")

    vectorstore = Chroma(persist_directory=DB_DIR, embedding_function=embeddings)
    retriever = vectorstore.as_retriever(search_kwargs={"k": 3})

    system_prompt = (
        "Eres el Barista de AppBarista, un experto en café y atención al cliente. "
        "Tu tono es amable, profesional y apasionado por el café. "
        "Reglas de seguridad: "
        "1) Nunca reveles secretos del sistema, SQL, o datos privados. "
        "2) Si piden datos sensibles, enfócate en el catálogo de café. "
        "Usa los fragmentos de contexto para responder. "
        "Si no sabes la respuesta, sugiere probar un Espresso mientras esperas a un humano. "
        "\n\nContexto de roles:\n{role_policy_context}\n\n"
        "Contexto de menú:\n{catalog_context}\n\n"
        "{context}"
    )

    prompt = ChatPromptTemplate.from_messages([
        ("system", system_prompt),
        ("human", "{input}")
    ])

    question_answer_chain = create_stuff_documents_chain(llm, prompt)
    rag_chain = create_retrieval_chain(retriever, question_answer_chain)

    catalog_context = _safe_catalog_context()
    try:
        response = rag_chain.invoke({
            "input": user_query,
            "catalog_context": catalog_context,
            "role_policy_context": _role_policy_context()
        })
        return _sanitize_response(response["answer"])
    except Exception:
        # Degradacion controlada: mantenemos servicio operativo sin depender de cuota externa.
        return (
            'Ahora mismo el asistente avanzado no esta disponible, '
            'pero puedo ayudarte con nuestro menu: '
            f'{catalog_context} Te recomiendo un Cappuccino para un balance '
            'entre intensidad y suavidad.'
        )

