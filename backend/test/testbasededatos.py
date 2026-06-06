#!/usr/bin/env python
"""
Script de verificación de conexión a Supabase PostgreSQL.
Lee credenciales del .env y valida la conexión a la base de datos.
"""
import os
import sys
from pathlib import Path

# Cargar variables del .env
from dotenv import load_dotenv

# Buscar .env en la raíz del backend (un nivel arriba de la carpeta test)
env_path = Path(__file__).parent.parent / '.env'
load_dotenv(env_path)
print(f"Cargando .env desde: {env_path}")
print(f"Archivo existe: {env_path.exists()}")
print()

# Obtener credenciales
SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_KEY')

print("=" * 70)
print("VERIFICACIÓN DE CONEXIÓN - SUPABASE API / DB")
print("=" * 70)
print()

# Validar que las credenciales estén presentes
print("[1] Verificando credenciales en .env...")
credenciales = {
    'SUPABASE_URL': SUPABASE_URL,
    'SUPABASE_KEY': SUPABASE_KEY,
}

missing = [k for k, v in credenciales.items() if not v]
if missing:
    print(f"✗ Credenciales faltantes: {', '.join(missing)}")
    sys.exit(1)

print("✓ Todas las credenciales están presentes")
print(f"  URL: {SUPABASE_URL}")
print()

# Intentar conexión con Supabase Client (como en el proyecto)
print("[2] Intentando conexión con Supabase Client...")
try:
    from supabase import create_client
    
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    print("✓ Cliente de Supabase inicializado correctamente")
    
    # Ejecutar consulta de prueba a una tabla (ej. 'test' como en main.py)
    print("  Realizando consulta de prueba a la tabla 'test'...")
    try:
        response = supabase.table("test").select("*").limit(1).execute()
        print(f"✓ Conexión a la base de datos exitosa!")
        print(f"  Datos recibidos: {response.data}")
    except Exception as e:
        print(f"⚠ Error al consultar tabla 'test': {e}")
        print("  Asegúrate de que la tabla 'test' exista en tu proyecto de Supabase.")
    
except ImportError:
    print("✗ supabase-py no está instalado")
    print("  Instalación: pip install supabase")
    sys.exit(1)
except Exception as e:
    print(f"✗ Error inesperado: {type(e).__name__}: {e}")
    sys.exit(1)

print()
print("=" * 70)
print("✓ VERIFICACIÓN COMPLETADA")
print("=" * 70)
