# Plan for Luxx

## Lessions Leaerned
    in future when trying to introduce a new operator
        - make a minimal luxx-file, and reuse an existing one, until it works
            then introduce the new operator

## Prio One
    [X] BLOCKER DONE 2025-04-27 19:01 fix scanner multiline comment/eof problem
    [X] DONE 2025-04-26 18:28 Bugfix, multiline comment did raise an error, while there was none, missing *if* 
    [X] DONE 2025-04-26 15:45 Arrays
        create, length, append, set at, get at

    [X] DONE 2025-04-26 16:10 Maps
        create, length, set at, get at
    
    [X] DONE 2025-04-26 18:11 Wrapper classes for global Array- and Map-functions

    [ ] OPEN simple Monitor to dig around in the structures set up by compiler/scanner and interpreter
    [ ] OPEN expand a dictionary into a template string, via FFI to dart
        use the operator % 
    [ ] OPEN file access via FFI (with and without exceptions)
    [ ] OPEN make an entry point into the interpreter like the run() - method in the aos_luxx_star
        - add an option for an Environment
        - return environment
    [ ] OPEN Interpreter needs to emit errors imedietly ... at the moment it waits till EoP (the caller does it)

## Prio two
    [ ] OPEN think about an FFI specifically for STB
    [ ] OPEN make the interpreter load a class library
    [ ] get all tests from here: https://github.com/munificent/craftinginterpreters/tree/master/test
    [ ] add Curcumber to STB/Luxx
    [ ] link classes, nodes do not need to know about them
    [ ] persistance
    [ ] simple input from files
        CSV files that get out rolled into Luxx Objects

## Prio three
    [ ] OPEN input function
    [ ] Contracts:
        - Requires, can be used for type safety 
        - Ensures, 
        - Invariant
        
    [ ] have a language construct that can trigger an exception in the interpreter

## todo
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
        for example: findCardContaining(it, from) as card -- this would introduce a variable card at point of usage holding the result
        exit keyword/statement.

## Ideas 
    [ ] OPEN OO/Graph Database on Luxx
    [ ] OPEN Tree Walking Multi Methods, like in "Adaptive Programming"
    [ ] 
    [ ] better test suit. The compiler ignores to many errors!
    [ ] OPEN make # an EOL Comment
        [ ] OPEN add also ``` "code"  ``` blocks, which get ignored by the scanner

[ ] LUXX the last literal used, should be in an helper variable "it" (or similar).
- better idea, there is always a helper "declared" and we set it manually where needed
- in theory, all "keywords" of a previous keyword message could be variables for reuse?
[ ] OPEN print parse tree, can be high level tokens just like print

[x] DONE 2025-04-25 03:06 Parser break point in source code be able to have a token (on lexer level?) like BRK that is interpreted by the parser to break in a breakpoint. 
    - break point markers or other message or information markers could be part of the tokens
    OPEN add some diagnostics output to it, like line surrounding tokens and allow an argument or some.
        treat it as end of line comment, scanner just eats till there

https://stackoverflow.com/questions/12636738/access-to-user-environment-variable
[ ] Put Environment Variables into a super global scope
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
[ ] conserve comments, add them to the next token
[ ] keyword as token, could be a 𒈨 or similar, followed by allowed "tokentypes". 
- interpreted by the scanner added to the keyword list and treated by the parser
[ ] high level variables like ClassName, so the program itself can access its environment
[ ] token needs a flag "is keyword", so if we want to get rid of semicolons, we look forward if the next token might/will start a new rule
[ ] OPEN dynamic compile on off switches, example:
  OFF abc

  ON abc
[ ] port to big decimal https://pub.dev/documentation/big_decimal/latest/

## Tokens
<- -> := ::= =>

## Keywords
   Prototype
   
## general features
    [1] add dart list and map
    [2] keyword methods
    - prototypes
    - delegation keyword for design patterns

## method not found?

## field not found

## solid classes
   Classes who's objects get initialized by the compiler
   Useful for stuff like:
   Rule ::= Number | Ident;
   
## Reflection
   as it says