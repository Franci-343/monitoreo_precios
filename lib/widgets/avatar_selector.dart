import 'package:flutter/material.dart';

class AvatarSelector extends StatefulWidget {
  final String? currentAvatarUrl;
  final Function(String avatarUrl) onAvatarSelected;

  const AvatarSelector({
    super.key,
    this.currentAvatarUrl,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarSelector> createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  // Lista de iconos disponibles
  static const List<IconData> availableIcons = [
    Icons.person,
    Icons.account_circle,
    Icons.face,
    Icons.emoji_emotions,
    Icons.sentiment_satisfied,
    Icons.psychology,
    Icons.engineering,
    Icons.school,
    Icons.work,
    Icons.business_center,
    Icons.sports_esports,
    Icons.sports_soccer,
    Icons.music_note,
    Icons.headphones,
    Icons.camera_alt,
    Icons.brush,
    Icons.palette,
    Icons.pets,
    Icons.favorite,
    Icons.star,
    Icons.emoji_food_beverage,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.cake,
    Icons.fastfood,
    Icons.icecream,
    Icons.rocket_launch,
    Icons.flight,
    Icons.directions_car,
    Icons.directions_bike,
    Icons.beach_access,
    Icons.wb_sunny,
    Icons.nightlight,
    Icons.ac_unit,
    Icons.eco,
    Icons.park,
  ];

  // Lista de colores disponibles
  static const List<Color> availableColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Púrpura
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Azul
    Color(0xFFEF4444), // Rojo
    Color(0xFFF97316), // Naranja
    Color(0xFFF59E0B), // Ámbar
    Color(0xFEEB77), // Amarillo
    Color(0xFF22C55E), // Verde
    Color(0xFF10B981), // Esmeralda
    Color(0xFF14B8A6), // Teal
    Color(0xFFEC4899), // Rosa
    Color(0xFFA855F7), // Violeta
    Color(0xFF64748B), // Gris pizarra
  ];

  late IconData selectedIcon;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    _parseCurrentAvatar();
  }

  void _parseCurrentAvatar() {
    if (widget.currentAvatarUrl != null &&
        widget.currentAvatarUrl!.startsWith('icon:')) {
      // Formato: "icon:10:0xFF6366F1" (índice del icono en la lista)
      final parts = widget.currentAvatarUrl!.split(':');
      if (parts.length >= 3) {
        // Parsear icono por índice
        try {
          final iconIndex = int.parse(parts[1]);
          if (iconIndex >= 0 && iconIndex < availableIcons.length) {
            selectedIcon = availableIcons[iconIndex];
          } else {
            selectedIcon = availableIcons[0];
          }
        } catch (e) {
          selectedIcon = availableIcons[0];
        }

        // Parsear color
        try {
          final colorHex = parts[2];
          selectedColor = Color(int.parse(colorHex));
        } catch (e) {
          selectedColor = availableColors[0];
        }
      } else {
        _setDefaults();
      }
    } else {
      _setDefaults();
    }
  }

  void _setDefaults() {
    selectedIcon = availableIcons[0];
    selectedColor = availableColors[0];
  }

  int _getIconIndex(IconData icon) {
    final index = availableIcons.indexOf(icon);
    return index >= 0 ? index : 0;
  }

  void _selectAvatar() {
    final iconIndex = _getIconIndex(selectedIcon);
    final avatarUrl =
        'icon:$iconIndex:0x${selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    widget.onAvatarSelected(avatarUrl);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.face_retouching_natural,
                  color: Color(0xFF00FFF0),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Personaliza tu Avatar',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Vista previa del avatar
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [selectedColor, selectedColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selectedColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(selectedIcon, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),

            // Selector de color
            const Text(
              'Elige un color',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: availableColors.length,
                itemBuilder: (context, index) {
                  final color = availableColors[index];
                  final isSelected = color == selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Selector de icono
            const Text(
              'Elige un icono',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                  ),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = availableIcons[index];
                    final isSelected = icon == selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = icon),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withOpacity(0.3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? selectedColor
                                : Colors.white.withOpacity(0.1),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 28,
                          color: isSelected ? selectedColor : Colors.white70,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón de confirmar
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [selectedColor, selectedColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _selectAvatar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Confirmar Avatar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para mostrar el avatar del usuario
class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({super.key, this.avatarUrl, this.size = 80, this.onTap});

  // Lista de iconos (misma que en AvatarSelector)
  static const List<IconData> availableIcons = [
    Icons.person,
    Icons.account_circle,
    Icons.face,
    Icons.emoji_emotions,
    Icons.sentiment_satisfied,
    Icons.psychology,
    Icons.engineering,
    Icons.school,
    Icons.work,
    Icons.business_center,
    Icons.sports_esports,
    Icons.sports_soccer,
    Icons.music_note,
    Icons.headphones,
    Icons.camera_alt,
    Icons.brush,
    Icons.palette,
    Icons.pets,
    Icons.favorite,
    Icons.star,
    Icons.emoji_food_beverage,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.cake,
    Icons.fastfood,
    Icons.icecream,
    Icons.rocket_launch,
    Icons.flight,
    Icons.directions_car,
    Icons.directions_bike,
    Icons.beach_access,
    Icons.wb_sunny,
    Icons.nightlight,
    Icons.ac_unit,
    Icons.eco,
    Icons.park,
  ];

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.person;
    Color color = const Color(0xFF6366F1);

    if (avatarUrl != null && avatarUrl!.startsWith('icon:')) {
      final parts = avatarUrl!.split(':');
      if (parts.length >= 3) {
        // Parsear color
        try {
          color = Color(int.parse(parts[2]));
        } catch (e) {
          color = const Color(0xFF6366F1);
        }

        // Parsear icono por índice
        try {
          final iconIndex = int.parse(parts[1]);
          if (iconIndex >= 0 && iconIndex < availableIcons.length) {
            icon = availableIcons[iconIndex];
          } else {
            icon = Icons.person;
          }
        } catch (e) {
          icon = Icons.person;
        }
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: size * 0.5, color: Colors.white),
            if (onTap != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFF0),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Color(0xFF0F0F23),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
