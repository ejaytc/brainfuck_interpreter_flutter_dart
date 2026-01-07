import 'dart:async';
import 'bf_memory.dart';


class BfCore {
  final Memory memory = Memory.init();
  final _outputController = StreamController<String>.broadcast();
  Stream<String> get outputStream => _outputController.stream;
  int dataPointer = 0;
  int instructionPointer = 0;
  String programSource;
  Completer<int>? _inputCompleter;
  BfCore(this.programSource);
  bool get isWaitingForInput =>
    _inputCompleter != null && !_inputCompleter!.isCompleted;

  bool _shouldStop = false;

  void stop() {
    _shouldStop = true;
  }

  Map<int, int> _jumpTable(String programSource) {
    final jumps = <int, int>{};
    final stack = <int>[]; // Temporary stack

    for (int index = 0; index < programSource.length; index++) {
      if (programSource[index] == '[') {
        stack.add(index);
      }
      else if (programSource[index] == ']') {
        int start = stack.removeLast();
        jumps[start] = index; // [ points to ]
        jumps[index] = start; // ] points to [
      }
    }
    return jumps;
  }


  Future<void> execute() async {
    Map<int, int> jumps = _jumpTable(programSource);
    int stepCount = 0;
    int maxSteps = 1000000;

    while (instructionPointer < programSource.length) {
      stepCount++;

      if (_shouldStop) {
        _outputController.add("\n^C (Execution Interrupted)\n");
        return;
      }

      // Terminate program if max steps reach.
      // if (stepCount > maxSteps){
      //   _outputController.add(
      //       "\n[SYSTEM ERROR]: Infinite loop detected. Killing process.\n"
      //   );
      //   return;
      // }

      //
      if (stepCount % 500 == 0) {
        await Future.delayed(Duration.zero);
      }
      String command = programSource[instructionPointer];
      switch(command) {
        case '>':
          dataPointer++;
          break;
        case '<':
          dataPointer--;
          break;
        case '[':
          if (memory.getMemoryBlock(dataPointer) == 0) {
           instructionPointer = jumps[instructionPointer]!;
          }
          break;
        case ']':
          if (memory.getMemoryBlock(dataPointer) != 0) {
            instructionPointer = jumps[instructionPointer]!;
          }
          break;
        case '+':
          memory.addValue(dataPointer, 1);
          break;
        case '-':
          memory.subtractValue(dataPointer, 1);
          break;
        case ',':
          _inputCompleter = Completer<int>();
          int input = await _inputCompleter!.future;
          memory.addInput(dataPointer, input);
          break;
        case '.':
          String outputChar = String.fromCharCode(
              memory.getMemoryBlock(dataPointer)
          );
          _outputController.add(outputChar);
      }
      instructionPointer++;
    }
  }

  void dispose(){
    _outputController.close();
  }

  void provideInput(int value) {
      _inputCompleter?.complete(value);
  }
}