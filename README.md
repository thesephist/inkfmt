# inkfmt

**inkfmt** is a code formatter for the [Ink programming language](https://github.com/thesephist/ink). It's written in Ink itself, and contains a self-hosting parser that generates a syntax tree that isn't comprehensive enough to use in the interpreter, but enough to autoformat code. inkfmt is designed to be run before a commit to canonicalize syntax and whitespaces. It makes these transformations:

- Remove redundant parentheses (from expression lists with a single expression)
- Remove unnecessary commas (rely on automatic comma insertion)
- Canonicalize whitespaces
    - Canonicalize indentation with tab character
    - Single spaces between specific tokens
    - Remove unnecessary lines leading and trailing a parenthesized expression

Notably, inkfmt does _not_ collapse multiline expressions into single lines, and conversely does not expand lines that are too long into multiple lines -- that's left to the developer's discretion.

## Usage

At this point, the `inkfmt` program reads Ink code in from `stdin` and writes formatted code and/or errors out to `stdout`. Eventually, the goal will be for the executable to read a tree of files and format all Ink programs within.

```
inkfmt < main.ink > main.ink
```

## Credits and references

- Phil Wadler's [Prettier Printer](https://homepages.inf.ed.ac.uk/wadler/papers/prettier/prettier.pdf)
- Prettier's JavaScript implementation of the above, [GitHub](https://github.com/prettier/prettier-printer)
