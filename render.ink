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

tabTimes := n => n > 0 :: {
	false -> ''
	_ -> (sub := (i, s) => i :: {
		0 -> s
		_ -> sub(i - 1, s + Tab)
	})(n, '')
}

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
	lines := ['']
	indents := [0]

	indent := {
		prev: 0
		curr: 0
	}

	` spaces are inserted by `
	each(tokens, (token, i) => (
		add := (s, tabs) => (
			trim(lines.(len(lines) - 1), Tab) :: {
				'' -> lines.(len(lines) - 1) := lines.(len(lines) - 1) + trimPrefix(s, ' ')
				_ -> lines.(len(lines) - 1) := lines.(len(lines) - 1) + s
			}

			indent.curr := indent.curr + tabs
		)

		last := tokens.(i - 1)
		next := tokens.(i + 1)
		[last, token, next] :: {
			[_, Newline, _] -> (
				tabDiff := indent.curr - indent.prev
				tabDiff > 0 :: {
					true -> indents.(len(indents) - 1) := indent.prev
					false -> indents.(len(indents) - 1) := indent.curr
				}

				indent.prev := indent.curr

				lines.len(lines) := ''
				indents.len(indents) := 0
			)
			[_, '.', _] -> add('.', 0)

			[_, ',', Newline] -> ()
			[_, '(', _] -> opSpaceAfter?(last) :: {
				true -> add(' (', 1)
				false -> add('(', 1)
			}
			[_, '[', _] -> opSpaceAfter?(last) :: {
				true -> add(' [', 1)
				false -> add('[', 1)
			}
			[_, '{', _] -> opSpaceAfter?(last) :: {
				true -> add(' {', 1)
				false -> add('{', 1)
			}

			[_, ')', _] -> add(')', ~1)
			[_, ']', _] -> add(']', ~1)
			[_, '}', _] -> add('}', ~1)

			[_, ',', _] -> add(token, 0)
			[_, ':', _] -> add(token, 0)
			['(', _, _] -> add(token, 0)
			['[', _, _] -> add(token, 0)
			['{', _, _] -> add(token, 0)
			['.', _, _] -> add(token, 0)
			['~', _, _] -> add(token, 0)
			_ -> add(' ' + token, 0)
		}
	))

	indentedLines := map(lines, (line, i) => tabTimes(indents.(i)) + line)
	cat(indentedLines, Newline)
)
