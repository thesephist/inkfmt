#!/usr/bin/env ink

` inkfmt: code formatter for ink `

std := load('vendor/std')
str := load('vendor/str')

log := std.log
f := std.format

Version := '0.1'

` The TokenRow is the main data type of inkfmt.
	it encodes information about a line's list of tokens
	and an indent level for the line. `
TokenRow := (tokens, indent) => {
	tokens: tokens,
	indent: indent,
}

` string -> [TokenRow] `
tokenize := code => (

)

` [TokenRow] -> string `
render := ast => (

)

main := (
	log(f('inkfmt v{{0}}', [Version]))

	` tokenize stdin into ast `
	` pass ast into renderer, which
		which deterministically renders it back into text `
)

