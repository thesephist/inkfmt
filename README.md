# inkfmt

**inkfmt** is a code formatter for the [Ink programming language](https://github.com/thesephist/ink). It's written in Ink itself, and contains a self-hosting parser that generates an AST that isn't comprehensive enough to use in the interpreter, but enough to autoformat code.

## Usage

At this point, the `inkfmt` program reads Ink code in from `stdin` and writes formatted code and/or errors out to `stdout`. Eventually, the goal will be for the executable to read a tree of files and format all Ink programs within.

```
inkfmt < main.ink > main.ink
```
