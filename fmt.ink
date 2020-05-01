#!/usr/bin/env ink
` inkfmt: code formatter for ink `

std := load('vendor/std')
str := load('vendor/str')

log := std.log
f := std.format

Version := '0.1'

tokenize := code => (

)

render := ast => (

)

main := (
	log(f('inkfmt v{{ version }}', {version: Version}))

	` tokenize stdin into ast `
	` pass ast into renderer, which
		which deterministically renders it back into text `
)

