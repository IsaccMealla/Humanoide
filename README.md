# ☕ Humanoid Coffee Co. — Robot Barista App

Sistema de control para un robot barista con brazos robóticos que prepara café de forma autónoma. Incluye una app móvil Flutter conectada en tiempo real a Supabase y un backend FastAPI.

---

## 📋 Tabla de Contenidos

- [Arquitectura](#-arquitectura)
- [Requisitos Previos](#-requisitos-previos)
- [Configuración de Supabase](#-configuración-de-supabase)
- [Frontend (Flutter)](#-frontend-flutter)
- [Backend (FastAPI)](#-backend-fastapi)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Paleta de Colores](#-paleta-de-colores)

---

## 🏗 Arquitectura

```
┌──────────────────┐     Realtime Streams     ┌──────────────────┐
│                  │◄────────────────────────►│                  │
│   Flutter App    │     REST API (CRUD)       │    Supabase      │
│   (Frontend)     │────────────────────────►│    (PostgreSQL)   │
│                  │                          │                  │
└──────────────────┘                          └────────┬─────────┘
                                                       │
┌──────────────────┐                                   │
│   FastAPI         │◄──────────────────────────────────┘
│   (Backend)       │       Supabase Python Client
└──────────────────┘
```

La app Flutter se comunica **directamente** con Supabase mediante:
- **Streams (Realtime)** para pedidos en tiempo real
- **REST** para leer el menú y crear pedidos

---

## ✅ Requisitos Previos

### Frontend
| Herramienta | Versión mínima |
|-------------|---------------|
| Flutter SDK | 3.11.5+       |
| Dart SDK    | 3.11.5+       |
| Chrome      | (para web)    |
| Android Studio / Xcode | (para móvil) |

### Backend
| Herramienta | Versión mínima |
|-------------|---------------|
| Python      | 3.10+         |
| pip         | 21+           |

### Servicios
| Servicio  | Descripción |
|-----------|-------------|
| Supabase  | Proyecto activo con las tablas configuradas |

---

## 🗄 Configuración de Supabase

### 1. Tablas requeridas

La app usa 3 tablas en el schema `public`:

#### `menu` — Catálogo de bebidas
```sql
CREATE TABLE menu (
  id BIGSERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  descripcion TEXT,
  precio NUMERIC(10,2) NOT NULL DEFAULT 0,
  imagen TEXT,
  disponible BOOLEAN DEFAULT true,
  creado_en TIMESTAMPTZ DEFAULT now()
);
```

#### `pedidos` — Órdenes del usuario
```sql
CREATE TABLE pedidos (
  id BIGSERIAL PRIMARY KEY,
  usuario_id TEXT DEFAULT 'anon',
  estado TEXT DEFAULT 'pendiente',  -- pendiente | preparando | listo | entregado
  total NUMERIC(10,2) DEFAULT 0,
  creado_en TIMESTAMPTZ DEFAULT now()
);
```

#### `detalle_pedidos` — Ítems de cada pedido
```sql
CREATE TABLE detalle_pedidos (
  id BIGSERIAL PRIMARY KEY,
  pedido_id BIGINT REFERENCES pedidos(id),
  menu_id BIGINT REFERENCES menu(id),
  cantidad INTEGER DEFAULT 1,
  subtotal NUMERIC(10,2) DEFAULT 0
);
```

### 2. Datos iniciales del menú

```sql
INSERT INTO menu (nombre, descripcion, precio, disponible) VALUES
  ('Cappuccino', 'Espresso con leche', 18.00, true),
  ('Espresso Clásico', 'Café espresso italiano puro, intenso y aromático', 15.00, true),
  ('Latte Macchiato', 'Leche vaporizada con un toque de espresso', 20.00, true),
  ('Mocha', 'Café con chocolate y leche vaporizada', 22.00, true),
  ('Americano', 'Espresso diluido en agua caliente', 14.00, true),
  ('Flat White', 'Espresso con microespuma de leche', 21.00, true),
  ('Chocolate Caliente', 'Chocolate belga con leche cremosa', 18.00, true),
  ('Matcha Latte', 'Té matcha japonés con leche vaporizada', 23.00, true);
```

### 3. Habilitar Realtime

Para que los streams funcionen en la app:

1. Ve a **Supabase Dashboard** → **Database** → **Replication**
2. Activa Realtime en las tablas: `pedidos`, `detalle_pedidos`
3. (Opcional) Activa en `menu` si deseas actualizar disponibilidad en tiempo real

### 4. Políticas RLS (Row Level Security)

Si RLS está habilitado, asegúrate de crear políticas permisivas para desarrollo:

```sql
-- Permitir lectura pública del menú
CREATE POLICY "Menu público" ON menu FOR SELECT USING (true);

-- Permitir CRUD en pedidos
CREATE POLICY "Pedidos públicos" ON pedidos FOR ALL USING (true);

-- Permitir CRUD en detalle_pedidos
CREATE POLICY "Detalles públicos" ON detalle_pedidos FOR ALL USING (true);
```

> ⚠️ **En producción**, restringe estas políticas según la autenticación del usuario.

---

## 📱 Frontend (Flutter)

### Instalación

```bash
cd frontend
flutter pub get
```

### Configuración

La conexión a Supabase está en `lib/main.dart`. Actualiza las credenciales si cambias de proyecto:

```dart
await Supabase.initialize(
  url: 'https://TU_PROYECTO.supabase.co',
  publishableKey: 'TU_ANON_KEY',
);
```

### Ejecutar

```bash
# Web (Chrome)
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios

# Listar dispositivos disponibles
flutter devices
```

### Análisis de código

```bash
flutter analyze
```

### Dependencias principales

| Paquete | Uso |
|---------|-----|
| `supabase_flutter` | Conexión y Realtime con Supabase |
| `google_fonts` | Tipografía Playfair Display + Inter |
| `flutter_animate` | Animaciones y transiciones |
| `flutter_riverpod` | Gestión de estado (disponible) |
| `go_router` | Navegación declarativa (disponible) |

### Vistas de la App

| Tab | Pantalla | Descripción |
|-----|----------|-------------|
| ☕ Menú | `menu_screen.dart` | Grid 2 columnas con bebidas, botón "Preparar ☕" |
| 📋 Pedidos | `pedidos_screen.dart` | Lista en tiempo real, stepper de proceso, chips de estado |
| 🤖 Robot | `robot_screen.dart` | Vaso animado, progreso %, timeline detallado |
| 🛑 Emergencia | `app_shell.dart` | Botón persistente en todas las vistas |

---

## ⚙️ Backend (FastAPI)

### Instalación

```bash
cd backend

# Crear entorno virtual
python -m venv venv

# Activar (Windows)
venv\Scripts\activate

# Activar (macOS/Linux)
source venv/bin/activate

# Instalar dependencias
pip install -r requirements_minimal.txt
```

### Configuración

Crea o edita el archivo `.env` en la carpeta `backend/`:

```env
SUPABASE_URL=https://TU_PROYECTO.supabase.co
SUPABASE_KEY=TU_ANON_KEY
```

### Ejecutar

```bash
uvicorn app.main:app --reload --port 8000
```

El servidor estará disponible en `http://localhost:8000`.

### Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/` | Health check |
| GET | `/test-supabase` | Test de conexión a Supabase |

---

## 📂 Estructura del Proyecto

```
barista-app/
├── README.md
│
├── backend/                          # API Python
│   ├── .env                          # Variables de entorno
│   ├── requirements_minimal.txt      # Dependencias Python
│   └── app/
│       ├── main.py                   # Entry point FastAPI
│       └── core/
│           ├── config.py             # Carga de env vars
│           └── database.py           # Cliente Supabase
│
└── frontend/                         # App Flutter
    ├── pubspec.yaml                  # Dependencias Dart
    └── lib/
        ├── main.dart                 # Entry point + Supabase init
        │
        ├── core/theme/
        │   ├── app_colors.dart       # Paleta Warm Coffee
        │   └── app_theme.dart        # ThemeData completo
        │
        ├── shared/
        │   ├── models/
        │   │   ├── menu_item_model.dart     # Modelo tabla menu
        │   │   └── pedido_model.dart        # Modelo pedidos + detalle + enum
        │   └── data/
        │       └── supabase_service.dart    # Servicio con streams y CRUD
        │
        └── features/dashboard/presentation/
            └── screens/
                ├── app_shell.dart           # Shell con NavigationBar + emergencia
                ├── menu_screen.dart         # Vista del menú (grid)
                ├── pedidos_screen.dart       # Vista de pedidos (real-time)
                └── robot_screen.dart        # Vista del robot (balanza)
```

---

## 🎨 Paleta de Colores

La app usa la estética **"Warm Coffee"** — cálida, limpia y minimalista:

| Color | Hex | Uso |
|-------|-----|-----|
| Espresso Oscuro | `#1A0F0A` | Fondo principal |
| Café Tostado | `#2A1F1A` | Superficies / cards |
| Café Medio | `#3D2E24` | Bordes / divisores |
| Crema | `#F5EBE6` | Texto principal |
| Hueso | `#D4C5BB` | Texto secundario |
| Caramelo | `#C68B59` | Acento principal / botones |
| Rojo Arcilla | `#A63D2F` | Emergencia |
| Verde Oliva | `#6B8F4E` | Éxito / completado |
| Ámbar Cálido | `#D4A03C` | En proceso / advertencia |

**Tipografía:**
- **Títulos:** Playfair Display (serif elegante)
- **Cuerpo:** Inter (sans-serif legible)

---

## 🚀 Flujo de Uso

1. **Abrir la app** → Se carga el menú desde Supabase
2. **Seleccionar bebida** → Presionar "Preparar ☕" crea un pedido
3. **Ver progreso** → La pestaña Pedidos muestra el estado en tiempo real
4. **Monitor del robot** → La pestaña Robot muestra el vaso llenándose
5. **Emergencia** → El botón rojo detiene los brazos robóticos

---

## 📝 Licencia

Proyecto académico / interno — Humanoid Coffee Co.
