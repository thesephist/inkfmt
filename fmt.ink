#!/usr/bin/env ink

` inkfmt: code formatter for ink `

std := load('vendor/std')
str := load('vendor/str')

log := std.log
cat := std.cat
readFile := std.readFile

lex := load('lex').lex
render := load('render').render

log := std.log
f := std.format

map := std.map
split := str.split
trim := str.trim

Version := '0.1-beta'
Newline := char(13)

main := (
	log(f('inkfmt v{{0}}', [Version]))

	` we can't rely on std.scan here to read stdin because
		std.scan reads by line, and we want to read until EOF `
	readFile('/dev/stdin', document => (
		formatted := render(lex(document))
		out(formatted)
	))
)

