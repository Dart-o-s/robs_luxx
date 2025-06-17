## Luxx Dart

An **upgraded** interpreter for the [Lox](https://github.com/munificent/craftinginterpreters) programming language written in Dart.

The project is based on a dart implementation done by: [Roboli](https://github.com/roboli/lox_dart).

See [plan.md](./plan.md) for the changes I made.

At the moment I am working on "Design by Contract" concepts:
    [x] the parser parses it, and we have the ast
    [ ] resolver and interpreter to go

## Small incomplete summary of additions
    + operator for strings
    # operator to interpolate variables from a hash-map into the string on the left hand side
    very simple support for Arrays and Maps
    a 'boot strap' directory, luxx files get loaded on start up from there (currently only a mini "standard library")
    the loader accepts a list of filenames, which it executes in the same VM
    a monitor, for fooling around purpose, after executing all luxx files, the loader drops into a monitor
        with some commands to examine the loaded classes, objects and functions
    some special key words which make the parser drop into the Dart debugger
        that means during development, you can have a "debug break" statement in the luxx source, 
        which makes the luxx parser halt at a break point, so you can investigate the parser

### Upgrades and History

Most of the work here is based on Roboli's implementation of the Lox language. I renamed it to Luxx and put in some "Upgrades".
This Git repository is new, I just wanted to push it upwards. So forgive me the bad shape, I will fix that.

The purpose of the language is to be a scripting language for a simple HyperCard clone. Also as I am interested in language design, I upgraded the language a bit, see: plan.md
