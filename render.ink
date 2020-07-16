` inkfmt: token list renderer `

std := load('vendor/std')
str := load('vendor/str')

log := std.log
f := std.format
range := std.range
slice := std.slice
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

tail := list => list.(len(list) - 1)

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
			trim(tail(lines), Tab) :: {
				'' -> lines.(len(lines) - 1) := tail(lines) + trimPrefix(s, ' ')
				_ -> lines.(len(lines) - 1) := tail(lines) + s
			}

			indent.curr := indent.curr + tabs
		)

		last := tokens.(i - 1)
		next := tokens.(i + 1)
		[last, token, next] :: {
			[_, Newline, _] -> (
				indents.(len(indents) - 1) := (indent.curr < indent.prev :: {
					true -> indent.curr
					false -> indent.prev
				})

				` if indent.prev != indents.(len(indents) - 2)
					and indents.(len(indents) - 2) == indent.curr
					add hanging indent. `
				lastIndent := indents.(len(indents) - 2) :: {
					() -> ()
					_ -> indent.prev > lastIndent & lastIndent = indent.curr :: {
						true -> indents.(len(indents) - 1) := tail(indents) + 1
					}
				}

				indent.prev := indent.curr

				lines.len(lines) := ''
				indents.len(indents) := 0
			)
			[_, '.', _] -> add('.', 0)

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

			[_, ',', Newline] -> ()
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

	each(indents, (n, i) => i :: {
		0 -> ()
		_ -> (
			nLast := indents.(i - 1)

			n < nLast :: {
				true -> (
					` backtrack to the line immediately following
						the first line where indent > n `
					target := (sub := j => (
						indents.(j) > n :: {
							true -> sub(j - 1)
							false -> j + 1
						}
					))(i - 1)

					indents.(target) - n > 1 :: {
						true -> (
							diff := indents.(target) - n
							correctDiff := 1
							toSubtractFromEachLine := diff - correctDiff

							log(f('collapsing indents: {{0}} ~ {{1}} by {{2}}'
								[target + 1, i, toSubtractFromEachLine]))
							each(range(target, i, 1), j => (
								indents.(j) := indents.(j) - toSubtractFromEachLine
							))
						)
					}
				)
			}
		)
	})

	indentedLines := map(lines, (line, i) => tabTimes(indents.(i)) + line)
	cat(indentedLines, Newline)
)
