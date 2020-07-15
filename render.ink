` inkfmt: token list renderer `

std := load('vendor/std')
str := load('vendor/str')

log := std.log
map := std.map
each := std.each
cat := std.cat

hasPrefix? := str.hasPrefix?
trimPrefix := str.trimPrefix
split := str.split
trim := str.trim

lex := load('lex')

Newline := char(10)
Tab := char(9)
Tab := '    '

tabTimes := n => (sub := (i, s) => i :: {
	0 -> s
	_ -> sub(i - 1, s + Tab)
})(n, '')

`` TODO: add a minifier / minification mode -- only spaces when necessary

opSpaceAfter? := token => token :: {
	'=>' -> true
	':=' -> true
	'::' -> true
	'->' -> true
	':' -> true
	'=' -> true
	'-' -> true
	'+' -> true
	'*' -> true
	'/' -> true
	'%' -> true
	'>' -> true
	'<' -> true
	'&' -> true
	'|' -> true
	'^' -> true
	'_' -> true
	',' -> true
	_ -> false
}

render := tokens => (
	state := {
		doc: ''
		indent: 0
	}

	` spaces are inserted by `
	each(tokens, (token, i) => (
		last := tokens.(i - 1)
		next := tokens.(i + 1)

		lines := split(state.doc, Newline)
		push := bit => trim(lines.(len(lines) - 1), Tab) :: {
			'' -> state.doc := state.doc + trimPrefix(bit, ' ')
			_ -> state.doc := state.doc + bit
		}

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
			[_, '(', _] -> opSpaceAfter?(last) :: {
				true -> push(' (')
				false -> push('(')
			}
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
