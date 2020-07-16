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

` create a string with N tabs in it `
tabTimes := n => n > 0 :: {
	false -> ''
	_ -> (sub := (i, s) => i :: {
		0 -> s
		_ -> sub(i - 1, s + Tab)
	})(n, '')
}

` does a token require a space to follow it
	in well-formatted code? `
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

` shorthand func for the last item of a list `
tail := list => list.(len(list) - 1)

` main pretty-printing routine `
render := tokens => (
	` we keep track of lines of code and their corresponding
		indent levels separately and merge them at the end.

		this turns out to be simpler than trying to adjust
		indentations while also adding on lines of code `
	lines := ['']
	indents := [0]

	` stores algorithm state re: current indent levels `
	indent := {
		prev: 0
		curr: 0
		` indicates whether the following line should have a hanging indent `
		hanging?: false
	}

	` shorthand function for adding tokens and spaces to
		their respective mutable accumulators `
	add := (s, tabs) => (
		trim(tail(lines), Tab) :: {
			'' -> lines.(len(lines) - 1) := tail(lines) + trimPrefix(s, ' ')
			_ -> lines.(len(lines) - 1) := tail(lines) + s
		}

		indent.curr := indent.curr + tabs
	)

	` in this loop, we ask whether a space should come before each token.
		as a result: a token is only responsible for adding a space
		before it, not after it `
	each(tokens, (token, i) => (

		last := tokens.(i - 1)
		next := tokens.(i + 1)
		[last, token, next] :: {
			[_, Newline, _] -> (
				` this match clause is responsible for computing the correct level
					of indentation for the line that comes before this current newline.

					as a result, we compute each line's indentation level only after
					we fully tokenize and write the line itself. `
				indents.(len(indents) - 1) := (indent.curr < indent.prev :: {
					true -> indent.curr
					false -> indent.prev
				})

				` hanging indents occur when a line must be indented because it follows
					an incomplete binary operator expression from the previous line. `
				indent.hanging? :: {
					true -> indents.(len(indents) - 1) := tail(indents) + 1
				}

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

				` set the hanging indent flag for this current line, so we can process
					it accordingly when we are done with this line. `
				indent.hanging? := (last :: {
					'=>' -> true
					':=' -> true
					'::' -> true
					'->' -> true
					':' -> true
					'.' -> true
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
					_ -> false
				})
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
			[_, ',', ')'] -> ()
			[_, ',', ']'] -> ()
			[_, ',', '}'] -> ()
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

	` indentation collapsing:

		sometimes, multiple delimiter openers in a single line
		or a callback being passed into a function will add
		multiple levels of indentation in the above algorithm, but
		we only really want to indent one level at a time visually,
		even if semantically there are multiple levels of nesting
		present. We try to detect and "collapse" these indentations
		into single levels of tab here.

		we do this by scanning lines and finding groups of lines
		that are indented by more than 1 level at a time, and
		de-indenting them until they're only indented one level. `
	each(indents, (n, i) => i :: {
		0 -> ()
		_ -> n < indents.(i - 1) :: {
			true -> (
				` backtrack to the line immediately following
					the first line where indent > n `
				target := (sub := j => indents.(j) > n :: {
					true -> sub(j - 1)
					false -> j + 1
				})(i - 1)

				` if the range from target to current line is
					indented by more than 1, de-dent them accordingly. `
				indents.(target) - n > 1 :: {
					true -> (
						diff := indents.(target) - n
						each(range(target, i, 1), j => (
							indents.(j) := indents.(j) - diff + 1
						))
					)
				}
			)
		}
	})

	indentedLines := map(lines, (line, i) => line :: {
		` we don't indent empty lines `
		'' -> ''
		_ -> tabTimes(indents.(i)) + line
	})
	cat(indentedLines, Newline)
)
