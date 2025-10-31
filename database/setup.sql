-- ============================================
-- MONITOREO DE PRECIOS - LA PAZ, BOLIVIA
-- Base de Datos Supabase - Script de Instalación
-- ============================================

-- PASO 1: CREAR TABLAS PRINCIPALES
-- ============================================

-- 1.1 Tabla de perfiles de usuario
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

-- 1.2 Tabla de mercados
CREATE TABLE public.mercados (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  zona VARCHAR(100) NOT NULL,
  direccion TEXT,
  latitud DECIMAL(10, 8),
  longitud DECIMAL(11, 8),
  tipo VARCHAR(50) DEFAULT 'mercado',
  horario_apertura TIME,
  horario_cierre TIME,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.3 Tabla de categorías
CREATE TABLE public.categorias (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT,
  icono VARCHAR(50),
  color VARCHAR(7),
  orden INT DEFAULT 0,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.4 Tabla de productos
CREATE TABLE public.productos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  categoria_id INT NOT NULL REFERENCES public.categorias(id) ON DELETE RESTRICT,
  descripcion TEXT,
  unidad_medida VARCHAR(20) DEFAULT 'unidad',
  imagen_url TEXT,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.5 Tabla de precios
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

-- 1.6 Tabla de favoritos
CREATE TABLE public.favoritos (
  id SERIAL PRIMARY KEY,
  usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
  producto_id INT NOT NULL REFERENCES public.productos(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(usuario_id, producto_id)
);

-- 1.7 Tabla de reportes de precios
CREATE TABLE public.reportes (
  id SERIAL PRIMARY KEY,
  usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
  producto_id INT NOT NULL REFERENCES public.productos(id) ON DELETE CASCADE,
  mercado_id INT NOT NULL REFERENCES public.mercados(id) ON DELETE CASCADE,
  precio_reportado DECIMAL(10, 2) NOT NULL CHECK (precio_reportado >= 0),
  estado VARCHAR(20) DEFAULT 'pendiente',
  fecha_reporte TIMESTAMPTZ DEFAULT NOW(),
  fecha_revision TIMESTAMPTZ,
  notas TEXT,
  foto_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.8 Tabla de alertas de precios
CREATE TABLE public.alertas (
  id SERIAL PRIMARY KEY,
  usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
  producto_id INT NOT NULL REFERENCES public.productos(id) ON DELETE CASCADE,
  mercado_id INT REFERENCES public.mercados(id) ON DELETE CASCADE,
  precio_objetivo DECIMAL(10, 2) NOT NULL CHECK (precio_objetivo >= 0),
  tipo_alerta VARCHAR(20) DEFAULT 'menor_o_igual',
  activo BOOLEAN DEFAULT TRUE,
  notificado BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- PASO 2: CREAR ÍNDICES
-- ============================================

-- Índices para usuarios
CREATE INDEX idx_usuarios_email ON public.usuarios(email);
CREATE INDEX idx_usuarios_zona ON public.usuarios(zona_preferida);

-- Índices para mercados
CREATE INDEX idx_mercados_zona ON public.mercados(zona);
CREATE INDEX idx_mercados_tipo ON public.mercados(tipo);
CREATE INDEX idx_mercados_activo ON public.mercados(activo);

-- Índices para categorías
CREATE INDEX idx_categorias_activo ON public.categorias(activo);
CREATE INDEX idx_categorias_orden ON public.categorias(orden);

-- Índices para productos
CREATE INDEX idx_productos_categoria ON public.productos(categoria_id);
CREATE INDEX idx_productos_nombre ON public.productos(nombre);
CREATE INDEX idx_productos_activo ON public.productos(activo);

-- Índices para precios
CREATE INDEX idx_precios_producto ON public.precios(producto_id);
CREATE INDEX idx_precios_mercado ON public.precios(mercado_id);
CREATE INDEX idx_precios_fecha ON public.precios(fecha_actualizacion DESC);
CREATE INDEX idx_precios_producto_mercado ON public.precios(producto_id, mercado_id);

-- Índices para favoritos
CREATE INDEX idx_favoritos_usuario ON public.favoritos(usuario_id);
CREATE INDEX idx_favoritos_producto ON public.favoritos(producto_id);

-- Índices para reportes
CREATE INDEX idx_reportes_usuario ON public.reportes(usuario_id);
CREATE INDEX idx_reportes_producto ON public.reportes(producto_id);
CREATE INDEX idx_reportes_mercado ON public.reportes(mercado_id);
CREATE INDEX idx_reportes_estado ON public.reportes(estado);
CREATE INDEX idx_reportes_fecha ON public.reportes(fecha_reporte DESC);

-- Índices para alertas
CREATE INDEX idx_alertas_usuario ON public.alertas(usuario_id);
CREATE INDEX idx_alertas_producto ON public.alertas(producto_id);
CREATE INDEX idx_alertas_activo ON public.alertas(activo);

-- ============================================
-- PASO 3: HABILITAR ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mercados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.precios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favoritos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reportes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alertas ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PASO 4: CREAR POLÍTICAS RLS
-- ============================================

-- Políticas para usuarios
CREATE POLICY "Los usuarios pueden ver su propio perfil"
  ON public.usuarios FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Los usuarios pueden actualizar su propio perfil"
  ON public.usuarios FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Los usuarios pueden insertar su propio perfil"
  ON public.usuarios FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Políticas para mercados (lectura pública)
CREATE POLICY "Todos pueden ver mercados activos"
  ON public.mercados FOR SELECT
  USING (activo = TRUE);

-- Políticas para categorías (lectura pública)
CREATE POLICY "Todos pueden ver categorías activas"
  ON public.categorias FOR SELECT
  USING (activo = TRUE);

-- Políticas para productos (lectura pública)
CREATE POLICY "Todos pueden ver productos activos"
  ON public.productos FOR SELECT
  USING (activo = TRUE);

-- Políticas para precios
CREATE POLICY "Todos pueden ver precios"
  ON public.precios FOR SELECT
  USING (TRUE);

CREATE POLICY "Usuarios autenticados pueden insertar precios"
  ON public.precios FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Políticas para favoritos
CREATE POLICY "Los usuarios pueden ver sus favoritos"
  ON public.favoritos FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "Los usuarios pueden insertar sus favoritos"
  ON public.favoritos FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Los usuarios pueden eliminar sus favoritos"
  ON public.favoritos FOR DELETE
  USING (auth.uid() = usuario_id);

-- Políticas para reportes
CREATE POLICY "Los usuarios pueden ver sus reportes"
  ON public.reportes FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "Los usuarios pueden crear reportes"
  ON public.reportes FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

-- Políticas para alertas
CREATE POLICY "Los usuarios pueden ver sus alertas"
  ON public.alertas FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "Los usuarios pueden gestionar sus alertas"
  ON public.alertas FOR ALL
  USING (auth.uid() = usuario_id);

-- ============================================
-- PASO 5: FUNCIONES Y TRIGGERS
-- ============================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a tablas con updated_at
CREATE TRIGGER update_usuarios_updated_at 
  BEFORE UPDATE ON public.usuarios
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mercados_updated_at 
  BEFORE UPDATE ON public.mercados
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_productos_updated_at 
  BEFORE UPDATE ON public.productos
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reportes_updated_at 
  BEFORE UPDATE ON public.reportes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_alertas_updated_at 
  BEFORE UPDATE ON public.alertas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

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

-- Trigger para crear perfil cuando se registra un usuario
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

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

-- Función para verificar alertas cuando se inserta un nuevo precio
CREATE OR REPLACE FUNCTION verificar_alertas()
RETURNS TRIGGER AS $$
BEGIN
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

-- ============================================
-- PASO 6: CREAR VISTAS
-- ============================================

-- Vista de precios actuales (más reciente por producto-mercado)
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

-- ============================================
-- PASO 7: DATOS INICIALES (SEEDS)
-- ============================================

-- Insertar categorías
INSERT INTO public.categorias (nombre, descripcion, icono, color, orden) VALUES
  ('Frutas', 'Frutas frescas de temporada', 'apple', '#FF6B6B', 1),
  ('Verduras', 'Verduras y hortalizas', 'carrot', '#4ECDC4', 2),
  ('Carnes', 'Carnes rojas y blancas', 'drumstick', '#FF8B94', 3),
  ('Lácteos', 'Leche y derivados', 'cheese', '#FFE66D', 4),
  ('Granos', 'Arroz, quinua, trigo, etc.', 'wheat', '#95E1D3', 5),
  ('Abarrotes', 'Productos de despensa', 'shopping-basket', '#A8E6CF', 6),
  ('Tubérculos', 'Papa, yuca, camote, etc.', 'potato', '#FFEAA7', 7),
  ('Condimentos', 'Especias y condimentos', 'pepper', '#FAB1A0', 8);

-- Insertar mercados (ejemplos de La Paz)
INSERT INTO public.mercados (nombre, zona, direccion, tipo, horario_apertura, horario_cierre) VALUES
  ('Mercado Rodriguez', 'Centro', 'Av. Ismael Montes', 'mercado', '06:00', '18:00'),
  ('Mercado Lanza', 'Centro', 'Calle Lanza', 'mercado', '06:00', '19:00'),
  ('Mercado Villa Fátima', 'Villa Fátima', 'Av. Landaeta', 'mercado', '06:00', '18:00'),
  ('Mercado Sopocachi', 'Sopocachi', 'Av. Ecuador', 'mercado', '06:00', '18:00'),
  ('Ketal Sopocachi', 'Sopocachi', 'Av. 20 de Octubre', 'supermercado', '08:00', '22:00'),
  ('IC Norte', 'San Pedro', 'Av. Baptista', 'supermercado', '08:00', '22:00'),
  ('Hipermaxi Achumani', 'Achumani', 'Av. Costanera', 'supermercado', '08:00', '22:00'),
  ('Mercado Camacho', 'Centro', 'Av. Camacho', 'mercado', '06:00', '19:00'),
  ('Mercado Buenos Aires', 'Miraflores', 'Av. Buenos Aires', 'mercado', '06:00', '18:00'),
  ('Tía Sopocachi', 'Sopocachi', 'Plaza Abaroa', 'supermercado', '07:00', '21:00');

-- Insertar productos ejemplo (Frutas)
INSERT INTO public.productos (nombre, categoria_id, descripcion, unidad_medida) VALUES
  -- Frutas
  ('Manzana Roja', 1, 'Manzana roja importada', 'kg'),
  ('Plátano', 1, 'Plátano nacional', 'docena'),
  ('Naranja', 1, 'Naranja para jugo', 'kg'),
  ('Papaya', 1, 'Papaya dulce', 'unidad'),
  ('Sandía', 1, 'Sandía grande', 'unidad'),
  ('Uva Negra', 1, 'Uva negra sin pepa', 'kg'),
  ('Mandarina', 1, 'Mandarina dulce', 'kg'),
  ('Durazno', 1, 'Durazno de temporada', 'kg'),
  
  -- Verduras
  ('Tomate', 2, 'Tomate fresco', 'kg'),
  ('Cebolla', 2, 'Cebolla blanca', 'kg'),
  ('Lechuga', 2, 'Lechuga crespa', 'unidad'),
  ('Zanahoria', 2, 'Zanahoria nacional', 'kg'),
  ('Brócoli', 2, 'Brócoli fresco', 'unidad'),
  ('Pimentón', 2, 'Pimentón rojo/verde', 'kg'),
  ('Espinaca', 2, 'Espinaca fresca', 'atado'),
  
  -- Carnes
  ('Carne de Res', 3, 'Carne de res sin hueso', 'kg'),
  ('Pollo Entero', 3, 'Pollo beneficiado', 'kg'),
  ('Carne de Cerdo', 3, 'Carne de cerdo', 'kg'),
  ('Pechuga de Pollo', 3, 'Pechuga sin hueso', 'kg'),
  
  -- Lácteos
  ('Leche PIL', 4, 'Leche entera PIL 1L', 'litro'),
  ('Yogurt Natural', 4, 'Yogurt natural 1L', 'litro'),
  ('Queso Fresco', 4, 'Queso fresco nacional', 'kg'),
  
  -- Granos
  ('Arroz Blanco', 5, 'Arroz blanco grano largo', 'kg'),
  ('Quinua Real', 5, 'Quinua real del altiplano', 'kg'),
  ('Fideo', 5, 'Fideo para sopa', 'kg'),
  
  -- Tubérculos
  ('Papa Imilla', 7, 'Papa imilla', 'kg'),
  ('Papa Holandesa', 7, 'Papa holandesa', 'kg'),
  ('Chuño', 7, 'Chuño negro', 'kg'),
  
  -- Abarrotes
  ('Azúcar', 6, 'Azúcar blanca', 'kg'),
  ('Sal', 6, 'Sal de mesa', 'kg'),
  ('Aceite', 6, 'Aceite vegetal 1L', 'litro');

-- ============================================
-- INSTALACIÓN COMPLETA
-- ============================================
-- Ejecuta este script en el SQL Editor de Supabase
-- para crear toda la estructura de la base de datos.
-- ============================================
