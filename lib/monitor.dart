///
/// Monitor, to inspect and manipulate the [Machine]
///

import "dart:io";

import "machine.dart";

///
/// Material and Instrument pattern, Monitor is the instrument
///
class Monitor {
  Machine machine = Machine();

  Monitor() {}

  void runRepl() {

    stdout.write('> ');
    var input = stdin.readLineSync();

    while (input != null) {
      if (input == "exit")
        break;

      if (input == "list classes")
        print (machine.classes);
      if (input == "list instances")
        print (machine.instances);
      if (input == "list functions")
        print(machine.functions);

      // todo: various load commands
      stdout.write('> ');
      input = stdin.readLineSync();

      // Todo AoS print errors
    }
  }

}