import 'package:flutter/material.dart';


const TextStyle terminalStyle = TextStyle(
  fontFamily: 'monospace',
  fontSize: 12.0,
  fontWeight: FontWeight.bold,
  color: Colors.greenAccent,
  height: 1.2,
);


class TerminalInput extends StatefulWidget {
  final Function(String) onExecute;

  const TerminalInput(
      {
        super.key,
        required this.onExecute,
      }
  );

  @override
  State<TerminalInput> createState() => _TerminalInputState();
}


class _TerminalInputState extends State<TerminalInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _terminalFocusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _terminalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _terminalFocusNode,
      autofocus: true,
      style: terminalStyle.copyWith(color: Colors.white),
      cursorColor: Colors.greenAccent,
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        prefixIcon: Padding(
          padding: EdgeInsets.all(2.0),
          child: Text('>', style: terminalStyle),
        ),
      ),
      onSubmitted: (value) {
        widget.onExecute(value);
        _controller.clear();
        _terminalFocusNode.requestFocus();
      },
    );
  }
}


class DisplayOutput extends StatefulWidget {
  final List<String> history;

  const DisplayOutput({
        super.key,
        required this.history,
      });

  @override
  State<DisplayOutput> createState() => _TerminalOutputState();
}

class _TerminalOutputState extends State<DisplayOutput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widget.history.map((text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(2.0),
        child: Text(
          '> $text',
          textAlign: TextAlign.left,
          style: terminalStyle,
        ),
      )).toList(),
    );
  }
}
