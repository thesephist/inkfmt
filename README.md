# inkfmt

**inkfmt** (pronounced "ink format") is a self-hosting code formatter for the [Ink programming language](https://github.com/thesephist/ink). It's written in Ink itself, and contains a lexer that generates a token stream that isn't comprehensive enough to use in the interpreter, but enough to autoformat code. inkfmt is designed to be run before a commit to canonicalize syntax and whitespaces. It makes these transformations:

- Remove unnecessary commas (rely on automatic comma insertion)
	- At end of lines
	- At end of expression lists
- Canonicalize whitespaces
    - Canonicalize indentation with tab character
    - Ensure single spaces between specific tokens, when appropriate

Notably, inkfmt does _not_ collapse multiline expressions into single lines, and conversely does not expand lines that are too long into multiple lines -- that's left to the developer's discretion.

## Usage

At this point, the `inkfmt` program reads Ink code in from `stdin` and writes formatted code and/or errors out to `stdout`. Eventually, the goal will be for the executable to read a tree of files and format all Ink programs within.

```
inkfmt < main.ink > main.ink
```

## Design

Ink's indentation rules as implemented in inkfmt`are simple, and implemented at the token stream level, with constructing a full AST.

- We put a single space between each individual token within a line, with the following exceptions, from high to low priority:
	- No space before and after `.`
	- No space before `,` and `:`
	- No space after unary operators
	- Space before `(...)` only if following an operator, not value
	- No space after `(`, `{`, `[` and before `)`, `}`, `]` 
- One indent level is added for:
	- each paired delimiter
	- each incomplete binary expression

## Credits and references

- Phil Wadler's [Prettier Printer](https://homepages.inf.ed.ac.uk/wadler/papers/prettier/prettier.pdf)
- Prettier's JavaScript implementation of the above, [GitHub](https://github.com/prettier/prettier-printer)
