# 👨‍💼 Panel de Administrador

## 📋 Descripción

El sistema ahora incluye un **Panel de Administrador** completo que permite gestionar todos los aspectos de la aplicación.

## 🔐 Acceso de Administrador

### Credenciales:
- **Email:** `fa8050386@gmail.com`
- **Contraseña:** `Nadloraya1`

### Cómo Funciona:
Cuando inicias sesión con el email del administrador, la aplicación automáticamente:
1. ✅ Detecta que eres administrador
2. ✅ Te redirige al **Panel de Administrador**
3. ✅ Oculta la interfaz normal de usuario
4. ✅ Muestra solo herramientas administrativas

## 🎨 Características del Panel

### 1. Dashboard
- Vista general con estadísticas
- Total de productos, mercados, categorías
- Reportes pendientes
- Usuarios registrados
- Precios registrados

### 2. Gestión de Productos (CRUD Completo)
- ✅ **Crear** nuevos productos
- ✅ **Leer/Ver** lista de productos
- ✅ **Actualizar** productos existentes
- ✅ **Eliminar** productos (marca como inactivo)
- 🔍 Búsqueda en tiempo real
- 📊 Muestra categoría y unidad de medida

### 3. Gestión de Mercados (Próximamente)
- Crear, editar y eliminar mercados
- Gestión de zonas y horarios
- Coordenadas GPS

### 4. Gestión de Categorías (Próximamente)
- Administrar categorías de productos
- Iconos y colores personalizados
- Orden de visualización

### 5. Gestión de Reportes (Próximamente)
- Ver reportes de usuarios
- Aprobar o rechazar precios reportados
- Moderación de contenido

## 🛠️ Arquitectura Técnica

### Archivos Creados:

```
lib/
├── services/
│   └── admin_service.dart          # Servicio para verificar admin
├── views/
│   └── admin/
│       ├── admin_panel_view.dart   # Panel principal con navegación
│       ├── admin_productos_view.dart  # CRUD de productos
│       ├── admin_mercados_view.dart   # Gestión de mercados
│       ├── admin_categorias_view.dart # Gestión de categorías
│       └── admin_reportes_view.dart   # Gestión de reportes
```

### Modificaciones:

- **`lib/views/login_view.dart`**
  - Detecta si el usuario es admin
  - Redirige al panel correspondiente

### Componentes Clave:

**AdminService:**
```dart
class AdminService {
  static const String adminEmail = 'fa8050386@gmail.com';
  static bool isAdmin(String email);
}
```

**Navegación Condicional:**
```dart
final isAdmin = AdminService.isAdmin(email);
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => isAdmin ? AdminPanelView() : HomeAfterLogin(),
  ),
);
```

## 🎯 Flujo de Usuario Admin

1. **Login:**
   - Ingresa email: `fa8050386@gmail.com`
   - Ingresa contraseña: `Nadloraya1`
   - Click en "Iniciar Sesión"

2. **Panel de Admin:**
   - Se abre automáticamente el panel
   - Sidebar con 5 secciones
   - Dashboard por defecto

3. **Gestión de Productos:**
   - Click en "Productos" en el sidebar
   - Ver lista de todos los productos
   - **Buscar:** Escribe en el campo de búsqueda
   - **Crear:** Click en "Nuevo Producto"
   - **Editar:** Click en ícono de lápiz
   - **Eliminar:** Click en ícono de basura

4. **Cerrar Sesión:**
   - Click en ícono de logout (arriba a la derecha)
   - Confirmar en el diálogo
   - Vuelve a la pantalla de login

## 🎨 Diseño Visual

### Colores del Panel:
- **Primario:** Rojo (#EF4444) - Admin distintivo
- **Fondo:** Gris oscuro (#111827)
- **Cards:** Gris medio (#1F2937)
- **Texto:** Blanco y gris claro

### Layout:
- **Sidebar fijo** a la izquierda con NavigationRail
- **Contenido principal** ocupa el resto
- **Header** con título y botón de logout
- **Responsive** y adaptable

## 🔒 Seguridad

- ✅ Solo el email específico tiene acceso admin
- ✅ No hay roles en base de datos (verificación por email)
- ✅ Políticas RLS de Supabase protegen las operaciones
- ✅ Doble confirmación para eliminar productos
- ⚠️ Para producción: implementar sistema de roles en DB

## 📊 CRUD de Productos - Detalles

### Crear Producto:
```
Campos:
- Nombre (requerido)
- Categoría (requerido, dropdown)
- Descripción (opcional)
- Unidad de Medida (requerido)
```

### Actualizar Producto:
- Mismo formulario que crear
- Campos pre-llenados con datos actuales
- Validación en tiempo real

### Eliminar Producto:
- No elimina físicamente
- Marca `activo = false` en la base de datos
- Confirmación requerida
- Deja de aparecer en la app de usuarios

## 🚀 Próximas Mejoras

### Fase 2 - Mercados:
- [ ] CRUD completo de mercados
- [ ] Mapa para ubicación GPS
- [ ] Gestión de horarios

### Fase 3 - Categorías:
- [ ] CRUD de categorías
- [ ] Selector de iconos
- [ ] Selector de colores
- [ ] Reordenamiento drag & drop

### Fase 4 - Reportes:
- [ ] Lista de reportes pendientes
- [ ] Aprobación/Rechazo de precios
- [ ] Notificaciones a usuarios

### Fase 5 - Usuarios:
- [ ] Lista de usuarios registrados
- [ ] Estadísticas por usuario
- [ ] Banear/Desbanear usuarios
- [ ] Sistema de roles y permisos

### Fase 6 - Analytics:
- [ ] Gráficas de precios
- [ ] Tendencias de mercado
- [ ] Productos más consultados
- [ ] Reportes en PDF/Excel

## 🐛 Testing

### Para Probar:
1. Inicia la app
2. Login con credenciales admin
3. Verifica que se muestra el panel admin
4. Prueba crear un producto
5. Prueba editar un producto
6. Prueba eliminar un producto
7. Cierra sesión
8. Login con usuario normal
9. Verifica que se muestra la app normal

## 💡 Notas Importantes

- El panel es **exclusivo para administradores**
- Los usuarios normales **nunca ven** el panel
- Las operaciones CRUD **respetan** las políticas RLS
- Los cambios son **inmediatos** en toda la app
- No hay cache, siempre datos frescos de Supabase

## 📝 Cambios en la Base de Datos

**No se requieren cambios** en la base de datos. Todo funciona con:
- Las tablas existentes
- Las políticas RLS actuales
- Los triggers configurados

## 🎓 Tecnologías Usadas

- **Flutter:** Framework UI
- **Supabase:** Backend y base de datos
- **Material Design 3:** Componentes UI
- **NavigationRail:** Navegación lateral
- **Forms & Validation:** Gestión de formularios

---

✨ **¡El panel de administrador está listo para usar!** ✨
