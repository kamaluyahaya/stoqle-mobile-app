import 'package:flutter/material.dart';

/// A reusable input row widget with a title (label) and a textfield
/// All underlined with a single border.
class DefaultInputRow extends StatefulWidget {
  final String title;
  final String hintText;
  final TextEditingController? controller;
  final bool isRequired;
  final TextInputType? keyboardType;
  final int maxLength;
  final ValueChanged<String>? onChanged; // ✅ added

  const DefaultInputRow({
    Key? key,
    required this.title,
    this.hintText = '',
    this.controller,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.maxLength = 50,
    this.onChanged, // ✅ new param
  }) : super(key: key);

  @override
  State<DefaultInputRow> createState() => _DefaultInputRowState();
}

class _DefaultInputRowState extends State<DefaultInputRow> {
  late TextEditingController _controller;
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    _listener = () {
      if (mounted) {
        setState(() {}); // rebuild only if widget is still in tree
      }
      if (widget.onChanged != null) {
        widget.onChanged!(_controller.text); // ✅ trigger callback
      }
    };

    _controller.addListener(_listener);
  }

  @override
  void dispose() {
    _controller.removeListener(_listener); // ✅ detach listener
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(text: widget.title),
                      if (widget.isRequired)
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Input field + counter
              Expanded(
                flex: 7,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: widget.keyboardType,
                        controller: _controller,
                        cursorColor: Colors.red,
                        maxLength: widget.maxLength,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        buildCounter:
                            (
                              _, {
                              required currentLength,
                              required isFocused,
                              required maxLength,
                            }) => null,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          border: InputBorder.none,
                          isDense: true,
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                        ),
                        validator: (value) {
                          if (widget.isRequired &&
                              (value == null || value.trim().isEmpty)) {
                            return '${widget.title} is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    Text(
                      "${_controller.text.length}/${widget.maxLength}",
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(thickness: 1, height: 1, color: Colors.grey[200]),
        ],
      ),
    );
  }
}
