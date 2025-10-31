# Base de Datos Supabase - Monitoreo de Precios La Paz

## 📋 Resumen del Sistema

Sistema de monitoreo de precios de productos en mercados de La Paz, Bolivia. Permite a los usuarios:
- Autenticación con email y contraseña
- Consultar y comparar precios de productos
- Guardar productos favoritos
- Reportar precios
- Ver tendencias y análisis

---

## 🗄️ Esquema de Base de Datos

### 1. Autenticación (Supabase Auth)

Supabase incluye un sistema de autenticación integrado (`auth.users`) que maneja:
- Registro con email y contraseña
- Login/Logout
- Recuperación de contraseña
- Verificación de email
- Sessions y tokens JWT

**No necesitas crear esta tabla**, viene incluida con Supabase.

---

### 2. Tabla: `usuarios` (Profiles)

Información adicional del perfil de usuario, vinculada a `auth.users`.

```sql
-- Tabla de perfiles de usuario
CREATE TABLE public.usuarios (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nombre VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  telefono VARCHAR(20),
  zona_preferida VARCHAR(100),
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para optimización
CREATE INDEX idx_usuarios_email ON public.usuarios(email);
CREATE INDEX idx_usuarios_zona ON public.usuarios(zona_preferida);

-- RLS (Row Level Security)
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver y editar su propio perfil
CREATE POLICY "Los usuarios pueden ver su propio perfil"
  ON public.usuarios FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Los usuarios pueden actualizar su propio perfil"
  ON public.usuarios FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Los usuarios pueden insertar su propio perfil"
  ON public.usuarios FOR INSERT
  WITH CHECK (auth.uid() = id);
```

---

### 3. Tabla: `mercados`

Información de mercados y supermercados en La Paz.

```sql
-- Tabla de mercados
CREATE TABLE public.mercados (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  zona VARCHAR(100) NOT NULL,
  direccion TEXT,
  latitud DECIMAL(10, 8),
  longitud DECIMAL(11, 8),
  tipo VARCHAR(50) DEFAULT 'mercado', -- mercado, supermercado, tienda
  horario_apertura TIME,
  horario_cierre TIME,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_mercados_zona ON public.mercados(zona);
CREATE INDEX idx_mercados_tipo ON public.mercados(tipo);
CREATE INDEX idx_mercados_activo ON public.mercados(activo);

-- RLS: Todos pueden leer mercados
ALTER TABLE public.mercados ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver mercados activos"
  ON public.mercados FOR SELECT
  USING (activo = TRUE);
```

---

### 4. Tabla: `categorias`

Categorías de productos (frutas, verduras, carnes, etc.).

```sql
-- Tabla de categorías
CREATE TABLE public.categorias (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT,
  icono VARCHAR(50), -- nombre del icono para la UI
  color VARCHAR(7), -- código hex del color (#FFFFFF)
  orden INT DEFAULT 0,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_categorias_activo ON public.categorias(activo);
CREATE INDEX idx_categorias_orden ON public.categorias(orden);

-- RLS: Todos pueden leer categorías
ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver categorías activas"
  ON public.categorias FOR SELECT
  USING (activo = TRUE);
```

---

### 5. Tabla: `productos`

Catálogo de productos disponibles.

```sql
-- Tabla de productos
CREATE TABLE public.productos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  categoria_id INT NOT NULL REFERENCES public.categorias(id) ON DELETE RESTRICT,
  descripcion TEXT,
  unidad_medida VARCHAR(20) DEFAULT 'unidad', -- kg, lb, unidad, litro, etc.
  imagen_url TEXT,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_productos_categoria ON public.productos(categoria_id);
CREATE INDEX idx_productos_nombre ON public.productos(nombre);
CREATE INDEX idx_productos_activo ON public.productos(activo);

-- RLS: Todos pueden leer productos
ALTER TABLE public.productos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver productos activos"
  ON public.productos FOR SELECT
  USING (activo = TRUE);
```

---

### 6. Tabla: `precios`

Registro de precios históricos de productos en mercados.

```sql
-- Tabla de precios
CREATE TABLE public.precios (
  id SERIAL PRIMARY KEY,
  producto_id INT NOT NULL REFERENCES public.productos(id) ON DELETE CASCADE,
  mercado_id INT NOT NULL REFERENCES public.mercados(id) ON DELETE CASCADE,
  precio DECIMAL(10, 2) NOT NULL CHECK (precio >= 0),
  fecha_actualizacion TIMESTAMPTZ DEFAULT NOW(),
  verificado BOOLEAN DEFAULT FALSE,
  usuario_reporto_id UUID REFERENCES public.usuarios(id) ON DELETE SET NULL,
  notas TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para consultas rápidas
CREATE INDEX idx_precios_producto ON public.precios(producto_id);
CREATE INDEX idx_precios_mercado ON public.precios(mercado_id);
CREATE INDEX idx_precios_fecha ON public.precios(fecha_actualizacion DESC);
CREATE INDEX idx_precios_producto_mercado ON public.precios(producto_id, mercado_id);

-- RLS: Todos pueden leer precios
ALTER TABLE public.precios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver precios"
  ON public.precios FOR SELECT
  USING (TRUE);

CREATE POLICY "Usuarios autenticados pueden insertar precios"
  ON public.precios FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
```

---

### 7. Tabla: `favoritos`

Productos favoritos de cada usuario.

```sql
-- Tabla de favoritos
CREATE TABLE public.favoritos (
  id SERIAL PRIMARY KEY,
  usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
  producto_id INT NOT NULL REFERENCES public.productos(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Un usuario no puede tener el mismo producto como favorito dos veces
  UNIQUE(usuario_id, producto_id)
);

-- Índices
CREATE INDEX idx_favoritos_usuario ON public.favoritos(usuario_id);
CREATE INDEX idx_favoritos_producto ON public.favoritos(producto_id);

-- RLS: Los usuarios solo ven sus propios favoritos
ALTER TABLE public.favoritos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver sus favoritos"
  ON public.favoritos FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "Los usuarios pueden insertar sus favoritos"
  ON public.favoritos FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Los usuarios pueden eliminar sus favoritos"
  ON public.favoritos FOR DELETE
  USING (auth.uid() = usuario_id);
```

---

### 8. Tabla: `reportes`

Reportes de precios enviados por usuarios (para validación).

```sql
-- Tabla de reportes de precios
CREATE TABLE public.reportes (
  id SERIAL PRIMARY KEY,
  usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
  producto_id INT NOT NULL REFERENCES public.productos(id) ON DELETE CASCADE,
  mercado_id INT NOT NULL REFERENCES public.mercados(id) ON DELETE CASCADE,
  precio_reportado DECIMAL(10, 2) NOT NULL CHECK (precio_reportado >= 0),
  estado VARCHAR(20) DEFAULT 'pendiente', -- pendiente, aprobado, rechazado
  fecha_reporte TIMESTAMPTZ DEFAULT NOW(),
  fecha_revision TIMESTAMPTZ,
  notas TEXT,
  foto_url TEXT, -- URL de foto del precio (opcional)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_reportes_usuario ON public.reportes(usuario_id);
CREATE INDEX idx_reportes_producto ON public.reportes(producto_id);
CREATE INDEX idx_reportes_mercado ON public.reportes(mercado_id);
CREATE INDEX idx_reportes_estado ON public.reportes(estado);
CREATE INDEX idx_reportes_fecha ON public.reportes(fecha_reporte DESC);

-- RLS
ALTER TABLE public.reportes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver sus reportes"
  ON public.reportes FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "Los usuarios pueden crear reportes"
  ON public.reportes FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);
```

---

### 9. Tabla: `alertas`

Alertas de precios configuradas por usuarios.

```sql
-- Tabla de alertas de precios
CREATE TABLE public.alertas (
  id SERIAL PRIMARY KEY,
  usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
  producto_id INT NOT NULL REFERENCES public.productos(id) ON DELETE CASCADE,
  mercado_id INT REFERENCES public.mercados(id) ON DELETE CASCADE, -- NULL = cualquier mercado
  precio_objetivo DECIMAL(10, 2) NOT NULL CHECK (precio_objetivo >= 0),
  tipo_alerta VARCHAR(20) DEFAULT 'menor_o_igual', -- menor_o_igual, mayor_o_igual, cambio
  activo BOOLEAN DEFAULT TRUE,
  notificado BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_alertas_usuario ON public.alertas(usuario_id);
CREATE INDEX idx_alertas_producto ON public.alertas(producto_id);
CREATE INDEX idx_alertas_activo ON public.alertas(activo);

-- RLS
ALTER TABLE public.alertas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver sus alertas"
  ON public.alertas FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "Los usuarios pueden gestionar sus alertas"
  ON public.alertas FOR ALL
  USING (auth.uid() = usuario_id);
```

---

## 🔧 Funciones y Triggers

### Función: Actualizar timestamp automáticamente

```sql
-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas las tablas con updated_at
CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON public.usuarios
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mercados_updated_at BEFORE UPDATE ON public.mercados
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_productos_updated_at BEFORE UPDATE ON public.productos
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reportes_updated_at BEFORE UPDATE ON public.reportes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_alertas_updated_at BEFORE UPDATE ON public.alertas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Función: Crear perfil automáticamente al registrarse

```sql
-- Función para crear perfil de usuario automáticamente
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.usuarios (id, email, nombre)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'nombre', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger que se ejecuta cuando un usuario se registra
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### Función: Obtener precio promedio de un producto

```sql
-- Función para obtener precio promedio de un producto
CREATE OR REPLACE FUNCTION obtener_precio_promedio(producto_id_param INT)
RETURNS DECIMAL(10, 2) AS $$
DECLARE
  precio_avg DECIMAL(10, 2);
BEGIN
  SELECT AVG(precio) INTO precio_avg
  FROM public.precios
  WHERE producto_id = producto_id_param
    AND fecha_actualizacion >= NOW() - INTERVAL '7 days';
  
  RETURN COALESCE(precio_avg, 0);
END;
$$ LANGUAGE plpgsql;
```

### Función: Verificar alertas de precios

```sql
-- Función para verificar alertas cuando se inserta un nuevo precio
CREATE OR REPLACE FUNCTION verificar_alertas()
RETURNS TRIGGER AS $$
BEGIN
  -- Actualizar alertas que cumplan la condición
  UPDATE public.alertas
  SET notificado = TRUE, updated_at = NOW()
  WHERE producto_id = NEW.producto_id
    AND (mercado_id IS NULL OR mercado_id = NEW.mercado_id)
    AND activo = TRUE
    AND notificado = FALSE
    AND (
      (tipo_alerta = 'menor_o_igual' AND NEW.precio <= precio_objetivo) OR
      (tipo_alerta = 'mayor_o_igual' AND NEW.precio >= precio_objetivo)
    );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para verificar alertas
CREATE TRIGGER trigger_verificar_alertas
  AFTER INSERT ON public.precios
  FOR EACH ROW EXECUTE FUNCTION verificar_alertas();
```

---

## 📊 Vistas Útiles

### Vista: Precios actuales (más recientes por producto-mercado)

```sql
-- Vista de precios actuales (el más reciente de cada producto en cada mercado)
CREATE OR REPLACE VIEW precios_actuales AS
SELECT DISTINCT ON (p.producto_id, p.mercado_id)
  p.id,
  p.producto_id,
  prod.nombre AS producto_nombre,
  prod.unidad_medida,
  p.mercado_id,
  m.nombre AS mercado_nombre,
  m.zona,
  p.precio,
  p.fecha_actualizacion,
  p.verificado
FROM public.precios p
JOIN public.productos prod ON p.producto_id = prod.id
JOIN public.mercados m ON p.mercado_id = m.id
WHERE prod.activo = TRUE AND m.activo = TRUE
ORDER BY p.producto_id, p.mercado_id, p.fecha_actualizacion DESC;
```

### Vista: Comparación de precios por zona

```sql
-- Vista de comparación de precios por zona
CREATE OR REPLACE VIEW comparacion_precios_zona AS
SELECT 
  prod.nombre AS producto,
  prod.categoria_id,
  m.zona,
  AVG(p.precio) AS precio_promedio,
  MIN(p.precio) AS precio_minimo,
  MAX(p.precio) AS precio_maximo,
  COUNT(DISTINCT p.mercado_id) AS num_mercados
FROM public.precios p
JOIN public.productos prod ON p.producto_id = prod.id
JOIN public.mercados m ON p.mercado_id = m.id
WHERE p.fecha_actualizacion >= NOW() - INTERVAL '7 days'
  AND prod.activo = TRUE
  AND m.activo = TRUE
GROUP BY prod.nombre, prod.categoria_id, m.zona;
```

### Vista: Productos más consultados (con favoritos)

```sql
-- Vista de productos más populares
CREATE OR REPLACE VIEW productos_populares AS
SELECT 
  p.id,
  p.nombre,
  p.categoria_id,
  c.nombre AS categoria_nombre,
  COUNT(DISTINCT f.usuario_id) AS num_favoritos,
  COUNT(DISTINCT pr.id) AS num_reportes
FROM public.productos p
LEFT JOIN public.categorias c ON p.categoria_id = c.id
LEFT JOIN public.favoritos f ON p.id = f.producto_id
LEFT JOIN public.reportes pr ON p.id = pr.producto_id
WHERE p.activo = TRUE
GROUP BY p.id, p.nombre, p.categoria_id, c.nombre
ORDER BY num_favoritos DESC, num_reportes DESC;
```

---

## 🔐 Row Level Security (RLS) - Resumen

### Política General:
- **Lectura pública**: Mercados, Categorías, Productos, Precios
- **Lectura privada**: Usuarios (solo su perfil), Favoritos, Reportes, Alertas
- **Escritura autenticada**: Usuarios autenticados pueden reportar precios y agregar favoritos
- **Escritura privada**: Solo el propietario puede modificar su perfil, favoritos y alertas

---

## 📦 Datos Iniciales (Seeds)

### Categorías iniciales

```sql
INSERT INTO public.categorias (nombre, descripcion, icono, color, orden) VALUES
  ('Frutas', 'Frutas frescas', 'apple', '#FF6B6B', 1),
  ('Verduras', 'Verduras y hortalizas', 'carrot', '#4ECDC4', 2),
  ('Carnes', 'Carnes rojas y blancas', 'drumstick', '#FF8B94', 3),
  ('Lácteos', 'Leche y derivados', 'cheese', '#FFE66D', 4),
  ('Granos', 'Arroz, quinua, etc.', 'wheat', '#95E1D3', 5),
  ('Abarrotes', 'Productos de despensa', 'shopping-basket', '#A8E6CF', 6);
```

### Mercados iniciales (ejemplo)

```sql
INSERT INTO public.mercados (nombre, zona, direccion, tipo) VALUES
  ('Mercado Rodriguez', 'Centro', 'Av. Ismael Montes', 'mercado'),
  ('Mercado Lanza', 'Centro', 'Calle Lanza', 'mercado'),
  ('Ketal Sopocachi', 'Sopocachi', 'Av. 20 de Octubre', 'supermercado'),
  ('IC Norte', 'San Pedro', 'Av. Baptista', 'supermercado'),
  ('Mercado Villa Fátima', 'Villa Fátima', 'Av. Landaeta', 'mercado');
```

---

## 🚀 Implementación en Supabase

### Pasos para implementar:

1. **Crear proyecto en Supabase**
   - Ve a https://supabase.com
   - Crea un nuevo proyecto
   - Guarda la URL y la API Key

2. **Ejecutar SQL**
   - En el dashboard de Supabase, ve a "SQL Editor"
   - Copia y pega el SQL en orden:
     1. Tablas principales
     2. Índices
     3. RLS policies
     4. Funciones y triggers
     5. Vistas
     6. Datos iniciales

3. **Configurar autenticación**
   - En "Authentication" > "Settings"
   - Habilita "Email" como provider
   - Configura templates de email si deseas

4. **Configurar Storage (opcional)**
   - Para fotos de productos y reportes
   - Crear bucket "product-images"
   - Crear bucket "price-reports"

---

## 📱 Integración con Flutter

### Dependencias necesarias:

```yaml
dependencies:
  supabase_flutter: ^2.0.0
  flutter_dotenv: ^5.1.0
```

### Variables de entorno (.env):

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
```

---

## 🎯 Próximos pasos

Una vez que apruebes este diseño, procederé a:
1. ✅ Actualizar los modelos Dart para que coincidan con la BD
2. ✅ Implementar servicios de autenticación con Supabase
3. ✅ Crear servicios para CRUD de productos, precios, favoritos, etc.
4. ✅ Actualizar las vistas para consumir datos reales

---

## 📝 Notas importantes

- **Email único**: Supabase Auth maneja la unicidad del email automáticamente
- **Contraseña**: Nunca se almacena en texto plano, Supabase la encripta
- **Verificación**: Puedes habilitar verificación de email desde el dashboard
- **Seguridad**: RLS asegura que los usuarios solo vean sus datos privados
- **Escalabilidad**: Los índices optimizan consultas para miles de registros
