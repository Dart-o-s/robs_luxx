/*
  The "foreign" function interface connecting Dart with Luxx.
 */

/// BOING BOING we need two!
/// one pipe into the Luxx world, and one pipe into the Dart world

/// GRR BOING BOING again.
/// except for having a call back variable on the dark side
/// the luxx side can provide a simple function. We do not need
/// the lists/queue.
///

import 'dart:collection';

typedef DartCallbackFunction = void Function();

void eatingDartCallBack() {
  while (gLuxxy.isNotEmpty) {
    var it = gLuxxy.removeAt(0);
    // todo the user of luxx has to implement something like this
    // and handle the events. To be called, set the global variable 'dart'
    // with this function
    print (it);
  }
}

void emptyDartCallBack() {
  print ("initialize the 'dart' global variable, with a call back function that can handle the events in the gQueue.");
  print ("this is the global variable 'dart' in luxx_dfi.dart.");
}

void emptyLuxxCallBack() {
  print ("initialize the 'luxx' global variable, with a call back function that can handle the events in the gQueue.");
  print ("this is the global variable 'luxx' in luxx_dfi.dart.");

  print("if you see this message, someone wanted to marshal messages/events to the Luxx side, but the Luxx interpreter is not reading them.");
}

// used to pipe events/calls/messages to the Luxx World
var gLuxxy = <Object>[];

// to call the Luxx side to eat the events.
// the Luxx side needs to put a call back function here.
DartCallbackFunction luxx = emptyLuxxCallBack;

// used by the Luxx Interpreter to pipe events/calls/messages to the Dart World
var gDarcy  = <Object>[];

// The Luxx World has to provide access to this variable for Luxx Scripts.
// The Dart World has to put a real call back here.
DartCallbackFunction dart = emptyDartCallBack;
