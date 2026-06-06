-- Migración para crear la tabla de prueba y esquema básico de AppBarista

-- 1. Tabla de prueba 'test' (usada en main.py y testbasededatos.py)
CREATE TABLE IF NOT EXISTS public.test (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insertar dato de prueba si la tabla está vacía
INSERT INTO public.test (name)
SELECT 'Conexión exitosa desde FastAPI'
WHERE NOT EXISTS (SELECT 1 FROM public.test LIMIT 1);

-- 2. Esquema para el Menú (Cafetería)
CREATE TABLE IF NOT EXISTS public.categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.products (
    id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES public.categories(id),
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Datos iniciales para el Barista Agent
INSERT INTO public.categories (name, description) VALUES
('Café', 'Bebidas calientes a base de espresso'),
('Fríos', 'Bebidas refrescantes y lattes helados')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.products (category_id, name, description, price) VALUES
((SELECT id FROM public.categories WHERE name = 'Café'), 'Espresso', 'Doble shot de café intenso', 2.50),
((SELECT id FROM public.categories WHERE name = 'Café'), 'Cappuccino', 'Espresso con leche texturizada y espuma', 3.50),
((SELECT id FROM public.categories WHERE name = 'Café'), 'Latte', 'Espresso con mucha leche cremosa', 3.75)
ON CONFLICT DO NOTHING;
