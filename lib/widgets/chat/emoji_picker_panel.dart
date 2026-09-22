import 'package:flutter/material.dart';

import '../../utils/theme.dart';

/// A self-contained emoji picker.
///
/// Built from plain Unicode strings rather than a package so it renders the
/// same on web and mobile and adds no dependency to the build.
class EmojiPickerPanel extends StatefulWidget {
  final ValueChanged<String> onEmojiSelected;
  final VoidCallback onBackspace;
  final double height;

  const EmojiPickerPanel({
    super.key,
    required this.onEmojiSelected,
    required this.onBackspace,
    this.height = 260,
  });

  @override
  State<EmojiPickerPanel> createState() => _EmojiPickerPanelState();
}

class _EmojiCategory {
  final String label;
  final IconData icon;
  final List<String> emojis;

  const _EmojiCategory(this.label, this.icon, this.emojis);
}

const List<_EmojiCategory> _categories = [
  _EmojiCategory('Smileys', Icons.emoji_emotions_outlined, [
    '😀','😃','😄','😁','😆','😅','🤣','😂','🙂','🙃',
    '😉','😊','😇','🥰','😍','🤩','😘','😗','😚','😙',
    '😋','😛','😜','🤪','😝','🤗','🤭','🤫','🤔','🤐',
    '😐','😑','😶','😏','😒','🙄','😬','😴','🤤','😪',
    '😮','😯','😲','🥱','😳','🥺','😢','😭','😤','😠',
    '😡','🤬','🤯','😰','😥','😓','🤥','😶‍🌫️','🥳','😎',
    '🤓','🧐','🤠','🥸','😈','👻','💀','🤖','🎃','👽',
  ]),
  _EmojiCategory('Gestures', Icons.back_hand_outlined, [
    '👍','👎','👌','🤌','🤏','✌️','🤞','🤟','🤘','🤙',
    '👈','👉','👆','👇','☝️','✋','🤚','🖐️','🖖','👋',
    '🤝','🙏','✍️','💅','🤳','💪','🦾','👏','🙌','👐',
  ]),
  _EmojiCategory('Love', Icons.favorite_outline, [
    '❤️','🧡','💛','💚','💙','💜','🖤','🤍','🤎','💔',
    '❣️','💕','💞','💓','💗','💖','💘','💝','💟','♥️',
    '😻','💑','💏','👩‍❤️‍👨','🌹','🌷','💐','🔥','✨','💫',
  ]),
  _EmojiCategory('Animals', Icons.pets_outlined, [
    '🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯',
    '🦁','🐮','🐷','🐸','🐵','🐔','🐧','🐦','🐤','🦆',
    '🦉','🦋','🐝','🐞','🐢','🐙','🐬','🐳','🦄','🐴',
  ]),
  _EmojiCategory('Food', Icons.restaurant_outlined, [
    '🍏','🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🫐',
    '🍒','🍑','🥭','🍍','🥥','🥝','🍅','🥑','🍆','🌽',
    '🍕','🍔','🍟','🌭','🌮','🌯','🍝','🍜','🍣','🍱',
    '🍰','🎂','🍪','🍫','🍬','🍩','🍦','☕','🍵','🍻',
  ]),
  _EmojiCategory('Activity', Icons.sports_esports_outlined, [
    '⚽','🏀','🏈','⚾','🎾','🏐','🏉','🎱','🏓','🏸',
    '🥅','⛳','🏹','🎣','🥊','🎿','🏂','🏄','🏊','🚴',
    '🎮','🎧','🎤','🎬','🎨','🎯','🎲','🎸','🥁','🏆',
  ]),
  _EmojiCategory('Travel', Icons.flight_takeoff_outlined, [
    '🚗','🚕','🚙','🚌','🏎️','🚓','🚑','🚲','🛵','🏍️',
    '✈️','🚀','🛸','🚁','⛵','🚢','🚂','🗺️','🏝️','🏔️',
    '🌋','🏖️','🌃','🌉','🎡','🎢','🗼','🗽','🏰','⛺',
  ]),
  _EmojiCategory('Symbols', Icons.emoji_symbols_outlined, [
    '💯','✅','❌','⭐','🌟','⚡','💥','💦','🎉','🎊',
    '🎁','🔔','💡','📌','🔒','⏰','📅','💬','💭','👀',
    '🆗','🆒','🔥','🌈','☀️','🌙','⛅','❄️','🍀','♾️',
  ]),
];

class _EmojiPickerPanelState extends State<EmojiPickerPanel> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final category = _categories[_selected];

    return Container(
      height: widget.height,
      color: Colors.white,
      child: Column(
        children: [
          /// Category tabs
          SizedBox(
            height: 46,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isActive = index == _selected;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: IconButton(
                    tooltip: _categories[index].label,
                    onPressed: () => setState(() => _selected = index),
                    icon: Icon(
                      _categories[index].icon,
                      size: 22,
                      color: isActive
                          ? AppTheme.primaryColor
                          : Colors.grey.shade500,
                    ),
                  ),
                );
              },
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          /// Emoji grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 48,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: category.emojis.length,
              itemBuilder: (context, index) {
                final emoji = category.emojis[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => widget.onEmojiSelected(emoji),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                );
              },
            ),
          ),

          /// Backspace row
          Divider(height: 1, color: Colors.grey.shade200),
          SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Backspace',
                  onPressed: widget.onBackspace,
                  icon: Icon(
                    Icons.backspace_outlined,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
