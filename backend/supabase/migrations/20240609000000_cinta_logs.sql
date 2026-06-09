-- Migración para el historial de la Cinta Transportadora
CREATE TABLE IF NOT EXISTS public.cinta_logs (
    id SERIAL PRIMARY KEY,
    event_type TEXT NOT NULL, -- 'sensor_ir', 'sensor_ultra', 'manual_command', etc.
    message TEXT NOT NULL,
    is_running BOOLEAN,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar RLS si es necesario o dejarlo público para desarrollo
ALTER TABLE public.cinta_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permitir lectura pública de logs" ON public.cinta_logs FOR SELECT USING (true);
CREATE POLICY "Permitir inserción desde backend" ON public.cinta_logs FOR INSERT WITH CHECK (true);
