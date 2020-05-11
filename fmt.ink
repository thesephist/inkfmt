#!/usr/bin/env ink

` inkfmt: code formatter for ink `

std := load('vendor/std')
str := load('vendor/str')

L := load('lex')
R := load('render')

log := std.log
f := std.format

map := std.map
split := str.split
trim := str.trim

Version := '0.1'
Newline := char(13)
Tab := char(9)

` The TokenRow is the main data type of inkfmt.
	it encodes information about a line's list of tokens
	and an indent level for the line. `
TokenRow := (indent, tokens) => {
	indent: indent,
	tokens: tokens,
}

` string -> [TokenRow] `
tokenize := code => (
	lines := split(code, Newline)
	tokenRows := map(lines, L.line)
)

` [TokenRow] -> string `
render := tokenRows => (
	lines := map(tokenRows, R.line)
	doc := join(lines, Newline)
)

main := (
	log(f('inkfmt v{{0}}', [Version]))

	` tokenize stdin into TR `
	` pass TR into renderer, which
		which deterministically renders it back into text `
)

