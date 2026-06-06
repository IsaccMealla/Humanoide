import os
import sys
from pathlib import Path
from dotenv import load_dotenv

# Configuración de rutas
BASE_DIR = Path(__file__).parent.parent
env_path = BASE_DIR / '.env'
load_dotenv(env_path)

def run_migration():
    """
    Ejecuta el archivo SQL de migración directamente en Supabase (PostgreSQL)
    usando el cliente de Supabase.
    """
    print(f"Buscando .env en: {env_path}")
    
    SUPABASE_URL = os.getenv('SUPABASE_URL')
    SUPABASE_KEY = os.getenv('SUPABASE_KEY')

    if not SUPABASE_URL or not SUPABASE_KEY:
        print("✗ Error: Faltan credenciales en el .env")
        return

    try:
        from supabase import create_client
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        # Leer el archivo SQL
        migration_file = BASE_DIR / 'supabase' / 'migrations' / '20240606000000_init_schema.sql'
        if not migration_file.exists():
            print(f"✗ Error: No se encontró el archivo de migración en {migration_file}")
            return

        with open(migration_file, 'r', encoding='utf-8') as f:
            sql_query = f.read()

        print(f"Ejecutando migración: {migration_file.name}...")
        
        # En Supabase Auth/API no siempre se puede ejecutar SQL plano via RPC 
        # a menos que tengas una función definida. 
        # Como alternativa para este entorno, informamos al usuario sobre SQL Editor.
        
        print("\n" + "="*60)
        print("MIGRACIÓN POSTGRESQL (SQL)")
        print("="*60)
        print("Copia y pega el siguiente código en el 'SQL Editor' de tu Dashboard de Supabase:")
        print("-" * 60)
        print(sql_query)
        print("-" * 60)
        
    except Exception as e:
        print(f"✗ Error: {e}")

if __name__ == "__main__":
    run_migration()
