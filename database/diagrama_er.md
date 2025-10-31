# Diagrama Entidad-Relación - Base de Datos Monitoreo de Precios

## 📊 Diagrama Visual

```
┌─────────────────────────┐
│   auth.users            │ (Supabase Auth - No crear)
│  ─────────────────────  │
│  • id (UUID) PK         │
│  • email                │
│  • encrypted_password   │
│  • created_at           │
└────────────┬────────────┘
             │
             │ 1:1
             ▼
┌─────────────────────────┐
│   usuarios (profiles)   │
│  ─────────────────────  │
│  • id (UUID) PK, FK     │◄──────┐
│  • nombre               │       │
│  • email                │       │
│  • telefono             │       │
│  • zona_preferida       │       │
│  • avatar_url           │       │
│  • created_at           │       │
│  • updated_at           │       │
└────────────┬────────────┘       │
             │                    │
        ┌────┴────┬───────────────┼──────────┐
        │         │               │          │
        │ 1:N     │ 1:N           │ 1:N      │ 1:N
        ▼         ▼               ▼          ▼
┌──────────┐ ┌────────────┐ ┌──────────┐ ┌──────────┐
│favoritos │ │ reportes   │ │ alertas  │ │ precios  │
└──────────┘ └────────────┘ └──────────┘ └──────────┘
     │             │             │             │
     │             │             │             │
     │             │             │             │
     └─────────────┴─────────────┴─────────────┘
                   │
                   │ N:1
                   ▼
        ┌─────────────────────┐
        │   productos         │
        │  ─────────────────  │
        │  • id (SERIAL) PK   │◄────────┐
        │  • nombre           │         │
        │  • categoria_id FK  │         │
        │  • descripcion      │         │
        │  • unidad_medida    │         │
        │  • imagen_url       │         │
        │  • activo           │         │
        │  • created_at       │         │
        │  • updated_at       │         │
        └──────────┬──────────┘         │
                   │                    │
                   │ N:1                │ 1:N
                   ▼                    │
        ┌─────────────────────┐         │
        │   categorias        │         │
        │  ─────────────────  │         │
        │  • id (SERIAL) PK   │         │
        │  • nombre           │         │
        │  • descripcion      │         │
        │  • icono            │         │
        │  • color            │         │
        │  • orden            │         │
        │  • activo           │         │
        │  • created_at       │         │
        └─────────────────────┘         │
                                        │
        ┌───────────────────────────────┘
        │
        │ N:1
        ▼
┌─────────────────────┐
│   mercados          │
│  ─────────────────  │
│  • id (SERIAL) PK   │
│  • nombre           │
│  • zona             │
│  • direccion        │
│  • latitud          │
│  • longitud         │
│  • tipo             │
│  • horario_apertura │
│  • horario_cierre   │
│  • activo           │
│  • created_at       │
│  • updated_at       │
└─────────────────────┘
        ▲
        │
        │ N:1
        │
┌─────────────────────────────────────┐
│   precios                           │
│  ─────────────────────────────────  │
│  • id (SERIAL) PK                   │
│  • producto_id FK                   │
│  • mercado_id FK                    │
│  • precio                           │
│  • fecha_actualizacion              │
│  • verificado                       │
│  • usuario_reporto_id FK (usuarios) │
│  • notas                            │
│  • created_at                       │
└─────────────────────────────────────┘
```

## 🔗 Relaciones Detalladas

### 1. Autenticación y Perfiles
```
auth.users (1) ──── (1) usuarios
- Un usuario autenticado tiene un perfil
- El perfil se crea automáticamente al registrarse
```

### 2. Usuarios y Favoritos
```
usuarios (1) ──── (N) favoritos (N) ──── (1) productos
- Un usuario puede tener muchos favoritos
- Un producto puede ser favorito de muchos usuarios
- RelaciónMany-to-Many
```

### 3. Usuarios y Reportes
```
usuarios (1) ──── (N) reportes
reportes (N) ──── (1) productos
reportes (N) ──── (1) mercados
- Un usuario puede crear muchos reportes
- Un reporte pertenece a un producto y un mercado
```

### 4. Usuarios y Alertas
```
usuarios (1) ──── (N) alertas
alertas (N) ──── (1) productos
alertas (N) ──── (0..1) mercados
- Un usuario puede tener muchas alertas
- Una alerta puede ser para cualquier mercado (NULL) o uno específico
```

### 5. Productos y Categorías
```
categorias (1) ──── (N) productos
- Una categoría tiene muchos productos
- Un producto pertenece a una categoría
```

### 6. Precios (Relación Triple)
```
productos (1) ──── (N) precios (N) ──── (1) mercados
- Un producto tiene precios en muchos mercados
- Un mercado tiene precios de muchos productos
- Guarda histórico de precios con timestamp
```

### 7. Precios y Usuarios (Reportador)
```
usuarios (0..1) ──── (N) precios.usuario_reporto_id
- Un precio puede tener un usuario que lo reportó (opcional)
- Un usuario puede reportar muchos precios
```

## 📋 Cardinalidades

| Relación | Tipo | Descripción |
|----------|------|-------------|
| auth.users → usuarios | 1:1 | Obligatoria, un usuario auth tiene un perfil |
| usuarios → favoritos | 1:N | Un usuario, muchos favoritos |
| productos → favoritos | 1:N | Un producto, muchos favoritos |
| usuarios → reportes | 1:N | Un usuario, muchos reportes |
| usuarios → alertas | 1:N | Un usuario, muchas alertas |
| categorias → productos | 1:N | Una categoría, muchos productos |
| productos → precios | 1:N | Un producto, muchos precios históricos |
| mercados → precios | 1:N | Un mercado, muchos precios |
| usuarios → precios | 0..1:N | Un usuario puede reportar precios (opcional) |

## 🎨 Modelo Conceptual Simplificado

```
USUARIOS
   ├── FAVORITOS ──► PRODUCTOS
   ├── REPORTES ──► PRODUCTOS + MERCADOS
   ├── ALERTAS ──► PRODUCTOS (+ MERCADOS opcional)
   └── PRECIOS_REPORTADOS

PRODUCTOS
   ├── Pertenece a CATEGORÍAS
   ├── Tiene PRECIOS en MERCADOS
   └── Puede estar en FAVORITOS y ALERTAS

MERCADOS
   └── Tienen PRECIOS de PRODUCTOS

PRECIOS (Tabla de hechos)
   ├── PRODUCTO
   ├── MERCADO
   ├── USUARIO que reportó (opcional)
   └── TIMESTAMP (histórico)
```

## 🔐 Seguridad (RLS - Row Level Security)

```
┌─────────────────┬──────────┬──────────┬──────────┬──────────┐
│ Tabla           │ SELECT   │ INSERT   │ UPDATE   │ DELETE   │
├─────────────────┼──────────┼──────────┼──────────┼──────────┤
│ usuarios        │ Own only │ Own only │ Own only │ ✗        │
│ categorias      │ All      │ ✗        │ ✗        │ ✗        │
│ productos       │ All      │ ✗        │ ✗        │ ✗        │
│ mercados        │ All      │ ✗        │ ✗        │ ✗        │
│ precios         │ All      │ Auth ✓   │ ✗        │ ✗        │
│ favoritos       │ Own only │ Own only │ ✗        │ Own only │
│ reportes        │ Own only │ Own only │ ✗        │ ✗        │
│ alertas         │ Own only │ Own only │ Own only │ Own only │
└─────────────────┴──────────┴──────────┴──────────┴──────────┘

Leyenda:
- All: Todos pueden ver (lectura pública)
- Own only: Solo el propietario (auth.uid() = usuario_id)
- Auth ✓: Cualquier usuario autenticado
- ✗: No permitido
```

## 🔄 Flujo de Datos Principal

### Flujo de Usuario Nuevo
```
1. Usuario se registra en Supabase Auth
   ↓
2. Trigger crea perfil en tabla 'usuarios'
   ↓
3. Usuario puede:
   - Ver productos, categorías, mercados (público)
   - Agregar favoritos
   - Reportar precios
   - Crear alertas
```

### Flujo de Consulta de Precios
```
1. Usuario busca un producto
   ↓
2. Sistema consulta 'precios' más recientes
   ↓
3. Agrupa por mercado y muestra comparación
   ↓
4. Usuario puede:
   - Agregar a favoritos
   - Crear alerta de precio
   - Reportar nuevo precio
```

### Flujo de Reporte de Precio
```
1. Usuario reporta precio (tabla 'reportes')
   ↓
2. Admin revisa y aprueba
   ↓
3. Se crea entrada en tabla 'precios'
   ↓
4. Trigger verifica alertas activas
   ↓
5. Marca alertas cumplidas como 'notificado'
```

## 📈 Consultas Optimizadas

### Índices Importantes
- **precios**: (producto_id, mercado_id) - Búsqueda de precios actuales
- **precios**: (fecha_actualizacion DESC) - Ordenar por más reciente
- **favoritos**: (usuario_id) - Listar favoritos de usuario
- **productos**: (categoria_id) - Filtrar por categoría
- **mercados**: (zona) - Filtrar por zona

### Vistas Pre-calculadas
1. **precios_actuales**: Precio más reciente por producto-mercado
2. **comparacion_precios_zona**: Promedio, min, max por zona
3. **productos_populares**: Productos con más favoritos

## 💾 Estimación de Almacenamiento

### Escenario: 6 meses de operación

```
Tabla         | Registros | Tamaño aprox
──────────────┼───────────┼──────────────
usuarios      | 1,000     | ~100 KB
categorias    | 20        | ~5 KB
mercados      | 50        | ~10 KB
productos     | 500       | ~50 KB
precios       | 150,000   | ~15 MB
favoritos     | 5,000     | ~200 KB
reportes      | 10,000    | ~1 MB
alertas       | 2,000     | ~100 KB
──────────────┴───────────┴──────────────
TOTAL estimado: ~17 MB
```

**Nota**: Supabase free tier incluye 500 MB de almacenamiento en base de datos.

---

## ✅ Verificación de Integridad

### Constraints Implementados
- ✅ PRIMARY KEYS en todas las tablas
- ✅ FOREIGN KEYS con ON DELETE apropiado
- ✅ UNIQUE constraints (email, categoría nombre, favorito único)
- ✅ CHECK constraints (precio >= 0)
- ✅ NOT NULL en campos críticos
- ✅ DEFAULT values apropiados
- ✅ Timestamps automáticos (created_at, updated_at)

### Triggers Automáticos
- ✅ Auto-crear perfil al registrarse
- ✅ Auto-actualizar updated_at
- ✅ Auto-verificar alertas al insertar precio

---

**Diseñado para**: Sistema de Monitoreo de Precios - La Paz, Bolivia  
**Fecha**: Octubre 2025  
**Versión**: 1.0  
**Base de datos**: PostgreSQL (Supabase)
