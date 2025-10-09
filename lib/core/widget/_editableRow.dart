import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A reusable row with [label] on the left,
/// [value] centered, and an arrow icon on the right.
/// Tapping triggers [onTap].
class EditableRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  // final Color labelColor;
  // final Color? valueColor;
  // final Color iconColor;

  const EditableRow({
    Key? key,
    required this.label,
    required this.value,
    required this.onTap,
    // this.labelColor = Colors.black54,
    // this.valueColor,
    // this.iconColor = Colors.black87,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Label (left)
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),

            // Value + Icon (right)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.isNotEmpty ? value : '$label',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A reusable row with [label] on the left
/// and a toggle switch on the right with red background when ON.
class EditableRowToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const EditableRowToggle({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label (left)
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),

          // Toggle (right)
          Container(
            height: 25,
            child: Transform.scale(
              scale: 0.8, // 0.8 = 80% of original size
              child: CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.red, // ON color
                trackColor: Colors.grey.shade400, // OFF color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
