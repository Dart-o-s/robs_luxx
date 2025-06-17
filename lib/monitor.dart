///
/// Monitor, to inspect and manipulate the [Machine]
///

import "dart:io";

import "interpreter.dart";
import "machine.dart";

///
/// Material and Instrument pattern, Monitor is the instrument
///
String help='''
   Todo: revert commands ... open a new screen
   list classes -> list all class names
   list instances -> list all instances and their class name
   list functions -> list all functions
   list intrinsics -> list the intrinsic functions
   
   # for this we make paging, always about 10, and hit a key to go deeper 
   select instance <#> -> fetch instance #x from the shown list and display internals
   Todo: 
    page tokens
    page statements
    search statements?
    
   exit -> leave the monitor
   todo: 
    select class and list methods
    select object/instance and 
''';
class Monitor {
  Machine machine = Machine();

  Monitor() {}

  void runRepl() {
    stdout.writeln(" =================================");
    stdout.writeln(" |-- Welcome to the Monitor ][ --|");
    stdout.writeln(" =================================");
    stdout.writeln('type: ? or help, for help.');
    stdout.write('> ');
    var input = stdin.readLineSync();

    while (input != null) {
      if (input == "exit")
        break;

      switch (input) {
        case "list classes":
          print(machine.classes);
        case "list instances":
          print(machine.instances);
        case "list functions":
          print(machine.functions);
        case "list intrinsics":
          Interpreter.listIntrinsics();
        break;
        case "help" || "?":
          print(help);
        break;
        default:
          print("noob! you typoed!");
      }
      // todo: various load commands
      stdout.write('> ');
      input = stdin.readLineSync();

      // Todo AoS print errors
    }
  }

}