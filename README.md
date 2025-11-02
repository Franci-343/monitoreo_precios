# 📱 Monitoreo de Precios - La Paz, Bolivia

Aplicación móvil y web para comparar precios de productos en mercados y supermercados de La Paz. Ayuda a los usuarios a encontrar las mejores ofertas y ahorrar en sus compras diarias.

## 🚀 Características

- 🔍 **Comparación de Precios**: Compara precios entre diferentes mercados y supermercados
- 📊 **Tendencias**: Visualiza el historial de precios y tendencias
- ⭐ **Favoritos**: Guarda tus productos favoritos para seguimiento rápido
- 🔔 **Alertas**: Recibe notificaciones cuando un producto alcanza tu precio objetivo
- 🗺️ **Mapa de Mercados**: Encuentra mercados por zona en La Paz
- 📝 **Reportes**: Los usuarios pueden reportar y actualizar precios
- 👨‍💼 **Panel Admin**: Gestión completa de productos, mercados y usuarios

## 🛠️ Tecnologías

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL + Auth)
- **Deployment**: 
  - Web: Vercel
  - Android: APK nativo

## 📂 Estructura del Proyecto

```
monitoreo_precios/
├── lib/
│   ├── main.dart                          # Punto de entrada, configuración Supabase y tema
│   ├── models/
│   │   ├── alerta_model.dart              # Modelo de alertas de precios
│   │   ├── categoria_model.dart           # Modelo de categorías de productos
│   │   ├── favorito_model.dart            # Modelo de productos favoritos
│   │   ├── mercado_model.dart             # Modelo de mercados/supermercados
│   │   ├── precio_model.dart              # Modelo de precios
│   │   ├── producto_model.dart            # Modelo de productos
│   │   ├── reporte_model.dart             # Modelo de reportes de usuarios
│   │   └── usuario_model.dart             # Modelo de perfil de usuario
│   ├── services/
│   │   ├── admin_service.dart             # Lógica de administrador
│   │   ├── alert_service.dart             # Gestión de alertas
│   │   ├── auth_service.dart              # Autenticación (login/registro)
│   │   ├── favorito_service.dart          # Gestión de favoritos
│   │   ├── historial_service.dart         # Historial de búsquedas
│   │   ├── precio_service.dart            # Consultas de precios
│   │   ├── producto_service.dart          # CRUD de productos
│   │   └── reporte_service.dart           # Sistema de reportes
│   ├── views/
│   │   ├── home_view.dart                 # Pantalla principal
│   │   ├── login_view.dart                # Inicio de sesión
│   │   ├── register_view.dart             # Registro de usuarios
│   │   ├── perfil_view.dart               # Perfil del usuario
│   │   ├── producto_view.dart             # Detalles de producto
│   │   ├── comparador_view.dart           # Comparar precios
│   │   ├── comparar_mercados_view.dart    # Comparar mercados
│   │   ├── donde_encontrar_view.dart      # Mapa de mercados
│   │   ├── precio_tendencia_view.dart     # Tendencias de precios
│   │   ├── favoritos_view.dart            # Lista de favoritos
│   │   ├── historial_view.dart            # Historial de búsquedas
│   │   ├── alertas_view.dart              # Gestión de alertas
│   │   ├── reporte_view.dart              # Reportar precios
│   │   └── admin/
│   │       ├── admin_panel_view.dart      # Panel principal admin
│   │       ├── admin_productos_view.dart  # CRUD productos
│   │       ├── admin_mercados_view.dart   # CRUD mercados
│   │       ├── admin_categorias_view.dart # CRUD categorías
│   │       ├── admin_usuarios_view.dart   # Gestión usuarios
│   │       └── admin_reportes_view.dart   # Revisar reportes
│   ├── widgets/
│   │   ├── alerta_banner.dart             # Banner de alertas
│   │   ├── avatar_selector.dart           # Selector de avatar
│   │   ├── loading_indicador.dart         # Indicador de carga
│   │   ├── mercado_selector.dart          # Selector de mercados
│   │   ├── precio_table.dart              # Tabla de precios
│   │   ├── producto_card.dart             # Tarjeta de producto
│   │   └── web3_widgets.dart              # Widgets glassmorphism
│   └── routes/
│       └── app_routes.dart                # Configuración de rutas
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml            # Permisos Android
├── web/
│   ├── index.html                         # HTML principal
│   └── manifest.json                      # Configuración PWA
├── pubspec.yaml                           # Dependencias del proyecto
├── vercel.json                            # Configuración Vercel
├── .env                                   # Variables de entorno
└── README.md                              # Este archivo
```

### Descripción de Carpetas

### `/lib` - Código Principal

#### `/lib/models` - Modelos de Datos
- `alerta_model.dart` - Modelo para alertas de precios
- `categoria_model.dart` - Categorías de productos (Frutas, Verduras, etc.)
- `favorito_model.dart` - Productos marcados como favoritos
- `mercado_model.dart` - Información de mercados y supermercados
- `precio_model.dart` - Registro de precios de productos
- `producto_model.dart` - Información de productos
- `reporte_model.dart` - Reportes de precios por usuarios
- `usuario_model.dart` - Perfil de usuario

#### `/lib/services` - Lógica de Negocio
- `admin_service.dart` - Verificación y operaciones de administrador
- `alert_service.dart` - Gestión de alertas de precios
- `auth_service.dart` - Autenticación (login, registro, logout)
- `favorito_service.dart` - Gestión de productos favoritos
- `historial_service.dart` - Seguimiento de historial de búsquedas
- `precio_service.dart` - Consultas y comparación de precios
- `producto_service.dart` - CRUD de productos
- `reporte_service.dart` - Sistema de reportes de usuarios

#### `/lib/views` - Pantallas de Usuario
- `home_view.dart` - Pantalla principal con búsqueda de productos
- `login_view.dart` - Inicio de sesión
- `register_view.dart` - Registro de nuevos usuarios
- `perfil_view.dart` - Perfil y configuración del usuario
- `producto_view.dart` - Detalles de un producto
- `comparador_view.dart` - Comparación de precios de un producto
- `comparar_mercados_view.dart` - Comparación entre mercados
- `donde_encontrar_view.dart` - Mapa de mercados por zona
- `precio_tendencia_view.dart` - Gráfico de tendencias de precios
- `favoritos_view.dart` - Lista de productos favoritos
- `historial_view.dart` - Historial de búsquedas
- `alertas_view.dart` - Gestión de alertas de precios
- `reporte_view.dart` - Formulario para reportar precios

#### `/lib/views/admin` - Panel de Administración
- `admin_panel_view.dart` - Menú principal del admin
- `admin_productos_view.dart` - Crear, editar, eliminar productos
- `admin_mercados_view.dart` - Gestión de mercados y supermercados
- `admin_categorias_view.dart` - Gestión de categorías
- `admin_usuarios_view.dart` - Ver, editar, eliminar usuarios
- `admin_reportes_view.dart` - Revisar reportes de usuarios

#### `/lib/widgets` - Componentes Reutilizables
- `alerta_banner.dart` - Banner de notificaciones de alertas
- `avatar_selector.dart` - Selector de avatar para perfil
- `loading_indicador.dart` - Indicador de carga personalizado
- `mercado_selector.dart` - Selector de mercados con filtros
- `precio_table.dart` - Tabla de comparación de precios
- `producto_card.dart` - Tarjeta de producto con diseño web3
- `web3_widgets.dart` - Componentes con efectos glassmorphism

#### `/lib/routes`
- `app_routes.dart` - Configuración de rutas de navegación

#### Archivo Principal
- `main.dart` - Punto de entrada, configuración de Supabase y tema

### `/android` - Configuración Android
- `AndroidManifest.xml` - Permisos (Internet, red)
- `build.gradle.kts` - Configuración de compilación

### `/web` - Configuración Web
- `index.html` - Página principal para web
- `manifest.json` - Configuración PWA

### Archivos de Configuración
- `pubspec.yaml` - Dependencias del proyecto
- `vercel.json` - Configuración de deployment en Vercel
- `.env` - Variables de entorno (Supabase credentials)

## 🗄️ Base de Datos (Supabase)

### Tablas Principales
- **usuarios** - Perfiles de usuario
- **productos** - Catálogo de productos
- **mercados** - Mercados y supermercados
- **categorias** - Categorías de productos
- **precios** - Histórico de precios
- **favoritos** - Productos favoritos por usuario
- **alertas** - Alertas de precio configuradas
- **reportes** - Reportes de precios por usuarios

### Seguridad
- **RLS (Row Level Security)** activado en todas las tablas
- Políticas específicas para usuarios normales y administradores
- Función `es_usuario_admin()` para verificación segura de admin

## 🔧 Instalación

### Requisitos
- Flutter SDK 3.9.2+
- Cuenta de Supabase
- (Opcional) Vercel para deployment web

### Configuración

1. **Clonar el repositorio**
```bash
git clone https://github.com/Franci-343/monitoreo_precios.git
cd monitoreo_precios
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Supabase**
   - Crea un proyecto en [Supabase](https://supabase.com)
   - Crea un archivo `.env` en la raíz:
```env
SUPABASE_URL=tu_url_de_supabase
SUPABASE_ANON_KEY=tu_anon_key
```

4. **Configurar la base de datos**
   - Ve al SQL Editor de Supabase
   - Ejecuta los scripts de la carpeta `/database` (solo localmente, no en repo)

### Ejecutar la Aplicación

**Web:**
```bash
flutter run -d chrome
```

**Android:**
```bash
flutter run
```

**Compilar para Producción:**
```bash
# APK Android
flutter build apk --release

# Web
flutter build web --release
```

## 👨‍💼 Panel de Administrador

**Credenciales por defecto:**
- Email: `fa8050386@gmail.com`
- (Configurar contraseña en Supabase)

**Funciones:**
- ✅ Crear, editar, eliminar productos
- ✅ Gestionar mercados y supermercados
- ✅ Administrar categorías
- ✅ Ver y gestionar usuarios
- ✅ Revisar reportes de precios

## 🎨 Diseño

La app utiliza un tema **Web3/Glassmorphism** con:
- Gradientes vibrantes (Indigo → Púrpura)
- Efectos de cristal translúcido
- Acentos neon cyan
- Modo oscuro por defecto

## 📄 Licencia

Este proyecto es de código abierto para fines educativos.

## 👨‍💻 Desarrollador

**Franco Mario Ayala Quispe**  
Ingeniería de Software - UMSA  
La Paz, Bolivia
