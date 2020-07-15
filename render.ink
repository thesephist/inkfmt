` inkfmt: token list renderer `

std := load('vendor/std')
str := load('vendor/str')

log := std.log
map := std.map
each := std.each
cat := std.cat

hasPrefix? := str.hasPrefix?

lex := load('lex')

Newline := char(10)
Tab := char(9)
Tab := '  '

tabTimes := n => (sub := (i, s) => i :: {
	0 -> s
	_ -> sub(i - 1, s + Tab)
})(n, '')

`` TODO: add a minifier / minification mode -- only spaces when necessary

render := tokens => (
	log(cat(tokens, '|'))
	state := {
		doc: ''
		indent: 0
	}

	push := bit => state.doc := state.doc + bit

	` spaces are inserted by `
	each(tokens, (token, i) => (
		last := tokens.(i - 1)
		next := tokens.(i + 1)

		token :: {
			'(' -> state.indent := state.indent + 1
			'[' -> state.indent := state.indent + 1
			'{' -> state.indent := state.indent + 1
			')' -> state.indent := state.indent - 1
			']' -> state.indent := state.indent - 1
			'}' -> state.indent := state.indent - 1
		}

		[last, token, next] :: {
			[_, '.', _] -> push(token)
			[_, Newline, ')'] -> push(Newline + tabTimes(state.indent - 1))
			[_, Newline, ']'] -> push(Newline + tabTimes(state.indent - 1))
			[_, Newline, '}'] -> push(Newline + tabTimes(state.indent - 1))
			[_, Newline, _] -> push(Newline + tabTimes(state.indent))
			[_, ',', Newline] -> ()
			[_, ')', _] -> push(token)
			[_, ']', _] -> push(token)
			[_, '}', _] -> push(token)
			[_, ',', _] -> push(token)
			[_, ':', _] -> push(token)
			['(', _, _] -> push(token)
			['[', _, _] -> push(token)
			['{', _, _] -> push(token)
			['.', _, _] -> push(token)
			['~', _, _] -> push(token)
			_ -> push(' ' + token)
		}
	))

	state.doc
)
