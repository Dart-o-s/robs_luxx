# Plan for Luxx - there should be light!

## Lessons Learned
    in future when trying to introduce a new operator
        - make a minimal luxx-file, and reuse an existing one, until it works
            then introduce the new operator

## Prio One
    [X] BLOCKER DONE 2025-04-27 19:01 fix scanner multiline comment/eof problem
    [X] DONE 2025-04-26 18:28 Bugfix, multiline comment did raise an error, while there was none, missing *if* 
    [X] DONE 2025-04-26 15:45 Arrays
        create, length, append, set at, get at

    [ ] BLOCKER OPEN some errors, parser or even interpreter cause an endless exception loop
        - that needs to be fixed before we can use STB on the tablet/phone

    [ ] OPEN Menu to call a function from Dart
        helper function in Luxx to find them

    [ ] OPEN create a Luxx object from the Dart side
        - create a Luxx class from Dart
        - create a Luxx method from Dart ... probably just "via text"

    [ ] OPEN Luxx meta programming, e.g. adding a method on the fly to a class, probbaly via a function
        - need reflection, too

    [X] DONE 2025-04-26 16:10 Maps
        create, length, set at, get at

    [x] OPEN check if we already have Generators
        yes we have, return a nested function as generator from a wrapepr function that creates it

    [X] DONE 2025-04-26 18:11 Wrapper classes for global Array- and Map-functions
    [X] DONE 2025-04-28 17:46 expand a dictionary into a template string, via FFI to dart
        use the operator %

    [ ] OPEN file access via FFI (with and without exceptions)
    [ ] OPEN make an entry point into the interpreter like the run() - method in the aos_luxx_star
        - add an option for an Environment
        - return environment
    [ ] OPEN Interpreter needs to emit errors imedietly ... at the moment it waits till EoP (the caller does it)

    [X] DONE 2025-04-28 21:03 list LoxInstances - put into runner
        Classes and instances

    [X] DONE 2025-04-28 22:49 simple Monitor to dig around in the structures set up by compiler/scanner and interpreter

    [X] DONE 2025-04-28 21:01 make the interpreter load a class library
        - use bootstrap in runner
        - files are loaded alphabetically
        [ ] OPEN for a later "import" statement, we need to remember which files are already loaded

    [X] DONE 2025-06-17 18:47 add --verbose and --no-boot-strap to aos_start_luxx.dart

    [ ] OPEN think how to make/declare "instance vars"
        as in, the init()-method initializes them, there could be list with names as in small-talk.

    [ ] OPEN make a hash keyword, behaves like var but instanciates a map
        example:
            hash myVar;
                myVar.something = "it";
                myVar.goingOn   = "yes!";
        
    [ ] OPEN treat "_" in function declarations as special identifier
        - it indicates the last param is a list, and arguments are put into a list
        - arguments get passed as a list in _

    [X] DONE 2025-06-19 23:47 Contracts:
        - Requires, can be used for type safety 
        - Ensures, 
        - Invariant
        [X] DONE 2025-06-18 16:09 make the parser parse them
        [X] DONE 2025-06-17 17:17 put them into the AST into the relevant function
        [X] DONE 2025-06-19 23:47 make the interpreter interpret them

    [ ] OPEN consider if the Resolver should/could break into the Monitor, on certain "break points"
    
    [X] DONE 2025-07-04 11:11 (Done a while ago) Luxx classes should be able to define a toString method (and others), which can
        be called from dart, for example when the '+' operator is expanded

    [_] DONE 2025-07-03 11:11 fix the "a" problem, it can not be a variable at the moment 
        [ ] OPEN scan the "is a" better with a look ahead
            if the scanner sees an "a" identifier, it only needs to check if the previous token was an "is" and change it

    [X] DONE 2025-04-29 01:00 BRK statement to get into the monitor.
        Copy/clone the print-statement
        [ ] OPEN - we need the same for the parser itself, and probably for the scanner, too

    [ ] OPEN Language statement to LOAD programms. Similar to import, but without managing if they were loaded already.
        - can be done like BRK
        OOPS, is that not closed and done? check ...

    [o] OPEN make LOAD statement first, to set up bigger test suits
    [ ] OPEN Working on persitence: write and read the token stream
        - lets first try serialization ...

    [X] DONE 2025-06-26 01:02 allow back tick identifiers
        - `this is an identifier containing spaces`

    [ ] OPEN introduce class defined operators, make the below possible
        [ ] OPEN filter expressions on lists/arrays (any collection) to apply a closure
            [some, items] /it.length >= 4/ { accu, curr | some code here; last line is returned } // result is a list or an accu

    [ ] OPEN figure what groups do in lox / luxx and how we can use them
    [ ] OPEN give classes/objects an intrinsic toHashMap() method, so it can be used in # - expressions
          OR: upgrade the interpreter to inspect right side of `#` and extract the map. 
### Monitor
    [ ] OPEN gather the old Monitor issues to here
    [ ] OPEN list all global variables - how could we forget that? 

## Prio two
    [ ] OPEN scanner needs to add the filename to the token
    [ ] OPEM FILE directive so 'files' loaded from strings, have a filename
        - actually even files have no filenames, haha. I mean: the parser and scanner reports line numbers without file information

    [ ] OPEN keywords for operators, just like identifier versus keyword, look first if an ident line "not"
        is an operator, and return that one to the parser

    [ ] OPEN JSONfy-method, 
        [x] DONE 2025-06-18 22:11 and toString()

    [ ] OPEN think about a punch card analogy for my various "card programs", to reference programs amoung each other
    [ ] OPEN think about an FFI specifically for STB

    [ ] get all tests from here: https://github.com/munificent/craftinginterpreters/tree/master/test

    [ ] add Curcumber to STB/Luxx
    [ ] link classes, nodes do not need to know about them
    [ ] persistance
    [ ] simple input from files
        CSV files that get out rolled into Luxx Objects

## Prio three
    [ ] OPEN input function

### Monitor

### Interpreter
    [ ] have a language construct that can trigger an exception in the interpreter

## todo - that is Prio four
    [x] DONE 2025-04-26 02:27 conocatanate doubles to sting ends
    [o] POSTPONED metaTokens to interprete directly by the parser or even scanner
        - scan to EOL and put it as value into the token
        - _meta::printAst
            for some reason the parser loses track if this instruction is on top level?

    [o] OPEN source code breakpoint, see STBLUXX
        - see above with _meta

    [X] DONE 2025-05-26 03:11 hang comments at the following token
    [X] DONE 2025-04-26 03:11 give keyword tokens a isKeyword flag
    [ ] OPEN Change string concatanation to StringBuffers
    [X] DONE 2025-04-26 13:05 Multi Line comments or the Scanner Switches (see below)
        - nested MLCs  
    [ ] LUXX return named result.
        int found = qaList.findCardContaining(it, from: cur);
        ^^^^^^^^^ this could be a "name" variable provided by the function
        for example: findCardContaining(it, from) as card -- this would introduce a variable 'card' at point of usage holding the result
        exit keyword/statement.

## Ideas 
    [ ] OPEN OO/Graph Database on Luxx
        integrate objectbox?

    [ ] OPEN Tree Walking Multi Methods, like in "Adaptive Programming"
        perhaps with a clever case construct:
        - case "path/of/objects" (that would be types) -> { code block };

    [ ] better test suit. The compiler ignores to many errors!
    [ ] OPEN make # an EOL Comment
        [ ] OPEN add also ``` "code"  ``` blocks, which get ignored by the scanner
    [ ] DI: a factory, just based on names (field names, that would overlap with being able to declare a list of field names)
    [ ] ensure/requires as methods with "infinite arguments", denoted as method(_);
        - this actually could be "intro blocks" of arbitrary name ...
    [ ] AST elements as data, e.g. @(some expressions) <- do not evaluate at point of encounter, but move as parameter/data around


    [ ] LUXX the last literal used, or return value, should be in an helper variable "it" (or similar).
        - better idea, there is always a helper "declared" and we set it manually where needed
        - in theory, all "keywords" of a previous keyword message could be variables for reuse?
    [ ] OPEN print parse tree, can be high level tokens just like print

    [x] DONE 2025-04-25 03:06 Parser break point in source code be able to have a token (on lexer level?) like BRK that is interpreted by the parser to break in a breakpoint. 
        - break point markers or other message or information markers could be part of the tokens
    [ ] OPEN add some diagnostics output to it, like line surrounding tokens and allow an argument or some.
        treat it as end of line comment, scanner just eats till there

    https://stackoverflow.com/questions/12636738/access-to-user-environment-variable
    [ ] OPEN Put Environment Variables into a super global scope
        - yes, the **env from C and export of BASH

[ ] Meta programming using Kanji, or Cuneiform
- 石 Ishi, stone for classes that get auto instantiated
- 矢 Ya, arrow message from the scanner
- () - message from resolver? Does that make sense? Would need to hang on "Ast Nodes"
- () - message from interpreter, as above
- 槍 Yari - message from parser
- 本 HON - letter
- https://en.wikipedia.org/wiki/Cuneiform_(Unicode_block)
- () -Chisel to emit bytecode
- 𒇞 - wow, cuneiform in my IntelliJ
- 𒆶 - looks okay, just do not know what it is, haha!
- 𒍶 DUB - tablet, make the parser spit out its Symbol table
- 𒄑 GES - tree, spit out AST
- 𒆸 LAGAB - block
- 𒈨 ME - the ME, yes 

[X] DONE 2025-06-11 11:11 - long ago conserve comments, add them to the next token
[ ] keyword as token, could be a 𒈨 or similar, followed by allowed "tokentypes". 
- interpreted by the scanner added to the keyword list and treated by the parser
[ ] high level variables like ClassName, so the program itself can access its environment
[ ] token needs a flag "is keyword", so if we want to get rid of semicolons, we look forward if the next token might/will start a new rule
[ ] OPEN dynamic compile on off switches, example:
  OFF abc

  ON abc
  - this could also be used as a comment on code, just marking a range of lines, highlighted in an editor,
    but having no "comment semantics" for the scanner
  
[ ] port to big decimal https://pub.dev/documentation/big_decimal/latest/

## Tokens
    Assignments: <- := ::= 
    Arrows right: -> =>
    Unary: * (poor mans pointers?)

## Keywords
self defined keywords

## Language Upgrades
    - Prototypes
    - constructs for Design Patterns, e.g. 
        o delegate <Class Name> to attribute;
    

## general features
    [1] DONE 2025-04-27 16:11 add dart list and map (done a while ago)
    [2] keyword methods
    - prototypes
    - delegation keyword for design patterns

## method not found?

## field not found

## solid classes - Japanese word used: 石 ishi
   Classes who's objects get initialized by the compiler
   Useful for stuff like:
   Rule ::= Number | Ident;
   
## Reflection
    as it says
    - start with listing the methods of a class

## Cracy
    some commands for class manipulation
    e.g. a Class could have a: create subclass command
        - one single meta class 'to rule them all', that can create classes and methods
        - likely a class itself would create its own methods
    simple enmums, like:
        o modes: edit, browse, creates a simple class "modes" and two instances edit and browse.
    concat operator for identifiers, example:
        some##test -> sometest. Or better, the contents if not nil/null yields a new identifier?
        var 'test' does not exist, 'some' = a: some##test -> atest. Some is resolved and test is taken as an atom.   
    value: 'undefined', like nil? Or is nil good enough?

    𒈨 ME: Use MD syntax for REST-calls, as in "[" + "]" to give the statement a pointy name, and have the parameters 
        gathered, and in "(" and ")" the URL (to be expanded by the parameters).
    add translation support into every App!

## for my assembly/jit/VM
    Calling a function comes into the new function with SP pointing at/behind return address.
    The function knows how many locals it has, and increases (decreases) SP acxcordingly.
    It remembers old SP ... to return, it sets old SP back and executes RTS.
    local variables are refered to as small offsets from SP, and arguments are refered to with bigger
    See the ARM assembly here: https://cs.lmu.edu/~ray/notes/compilerarchitecture/
                 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
    before call:  ^
    during call: arg1   arg2 [res]   ^                            // "during call" means pushing the args and an empty result slot, after that comes the call, not shown here, which pushes the return address
    during exec: arg1   arg2 [res]  ret  loc1  loc2   ^ 
    returned:     ^  ... ...   res

## ideas
    A LoxObject is not callable (yet), but could be.
    The hyper card like "On Event" constructs can be just ordinary classes, where the classname is
        bound to a card or item?
        - or like in a template? Should we have templates?
        Events would just be ordinary methods like onOpenCard() {}

    Can we integrate the "properties" into Card-Luxx for STB at least?
        - three calles: retrieve(), store() and delete()
    classes: OnStory<CardName>, OnChapter, OnBook, OnEpic, and so on?
    Supposed everything that makes STB 'HyperCard-ish' is written in Luxx. What would that mean, imply?

## HyperCard-ish ToDo's
    [ ] OPEN step I: passive "on event" handling, just calculations and input/outputs, no call backs into the "Card Engine"
    [ ] OPEN step II: call backs like "go to next card"
    Idea: could some commands just be simple multi word strings, like in the line above?

## knowledge
    https://stackoverflow.com/questions/32128111/intellij-external-tools-available-variables
    https://en.wikipedia.org/wiki/Box-drawing_characters - the "mini monitor" uses them
    https://pub.dev/packages/graphql_parser2/install
    https://pub.dev/documentation/graphql_codegen/latest/

For STB: https://github.com/termux/termux-app/discussions/2975 more SAF and picker related info!