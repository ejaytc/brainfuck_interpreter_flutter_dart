import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'terminal_io.dart';
import 'bf_core.dart';


void main()  => runApp(const BfTerminal());


const TextStyle terminalStyle = TextStyle(
  fontFamily: 'monospace',
  fontSize: 12.0,
  fontWeight: FontWeight.bold,
  color: Colors.greenAccent,
  height: 1.2,
);


class BfTerminal extends StatelessWidget {
  const BfTerminal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.green
        ),
        home: BfTerminalScreen()
    );
  }
}


class BfTerminalScreen extends StatefulWidget {
  const BfTerminalScreen({super.key});

  @override
  State<BfTerminalScreen> createState() => _BfTerminalScreenState();
}


class _BfTerminalScreenState extends State<BfTerminalScreen> {
  final ScrollController _mainScrollController = ScrollController();
  final List<String> _history = [];

  BfCore? _bfCore;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mainScrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 1), () {
          _mainScrollController.animateTo(
            _mainScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 10),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }

  void _handleBfOutput(String char) async {
    const int maxLineLength = 10000;
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      if (_history.isEmpty || char == '\n') {
        _history.add(char == '\n' ? "" : char);
        if (_history.length > maxLineLength) {
          _history.removeAt(0);
        }
      } else {
        _history[_history.length - 1] += char;
        if (_history.last.length > maxLineLength) {
          _history[_history.length - 1] = _history.last.substring(
              _history.last.length - maxLineLength
          );
        }
      }
      _scrollToBottom();
    });
  }

  void _handleUserCommand(String userInput) async{
    if (_bfCore != null && _bfCore!.isWaitingForInput) {
      int byte = userInput.isNotEmpty ? userInput.codeUnitAt(0) : 0;
      _bfCore!.provideInput(byte);
      return;
    }

    setState(() => _history.add("$userInput\n"));
    try {
      _bfCore?.dispose();
      _bfCore = BfCore(userInput);
      _bfCore!.outputStream.listen(_handleBfOutput);
      await _bfCore!.execute();
    }
    catch (e) {
      setState(() => _history.add("[Error]: ${e.toString()}"));
      print("${e.toString()}");
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
    _bfCore?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          // Bind Ctrl + C to the stop method
          const SingleActivator(LogicalKeyboardKey.keyC, control: true): () {
            _bfCore?.stop();
          },
        },
        child: Focus( // Focus is required to capture keyboard events
            autofocus: true,
            child:Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                  child: Scrollbar(
                      controller: _mainScrollController,
                      child: SingleChildScrollView(
                          controller: _mainScrollController,
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              DisplayOutput(
                                  history: _history,
                                  // scrollController: _mainScrollController,
                              ),
                              const Divider(color: Colors.white24),
                              TerminalInput(onExecute: _handleUserCommand)
                            ],
                          )
                      )
                  )
              ),
            ),
        )
      );
  }
}