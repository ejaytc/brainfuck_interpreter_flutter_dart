extension type Memory(({List<int> memoryBlock, List<int> stack}) data){
  static const int pointerLimit = 30000;

  factory Memory.init() => Memory((
    memoryBlock: List.filled(pointerLimit, 0, growable: false),
    stack: <int> []
  ));

  // Getter: Current memory block.
  int getMemoryBlock(int memoryPointer) =>
      data.memoryBlock[memoryPointer % pointerLimit];

  void addValue(int memoryPointer, int value) {
    int index = memoryPointer % pointerLimit;
    // Perform addition, then force 8-bit wrapping
    data.memoryBlock[index] = (data.memoryBlock[index] + value) & 0xFF;
  }
      // data.memoryBlock[memoryPointer % pointerLimit] += value & 0xFF;

  void subtractValue(int pointer, int value) {
    int index = pointer % pointerLimit;
    // Perform subtraction, then force 8-bit wrapping
    // In Dart, (-1 & 0xFF) correctly results in 255
    data.memoryBlock[index] = (data.memoryBlock[index] - value) & 0xFF;
  }
      // data.memoryBlock[pointer % pointerLimit] -= value & 0xFF;

  void addInput(int pointer, int value){
    data.memoryBlock[pointer % pointerLimit] = value & 0xFF;
  }

  List<int> viewMemory({int? start, int? end}) {
    return _view(data.memoryBlock, start: start, end: end);
  }

  List<int> viewStack({int? start, int? end}) {
    return _view(data.memoryBlock, start: start, end: end);
  }

  List<int> _view(List<int> data, {int? start, int? end}) {
    if (start != null && end != null) {
      return data.sublist(start, end);
    }
    else if (start != null) {
      return data.sublist(start);
    }
    else if (end != null) {
      return data.sublist(0, end);
    }
    return List<int>.from(data);
  }

  void resetMemory() {
    data.memoryBlock.fillRange(0, pointerLimit, 0);
    data.stack.clear();
  }
}
