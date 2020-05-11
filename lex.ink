` inkfmt parser internals `

str := load('vendor/str')

trimPrefix := str.trimPrefix

Newline := char(13)
Tab := char(9)

Symbols := [
	` we test for longer symbols first `
	'=>'
	':='
	'::'
	'->'
	':'
	'.'
	'='
	'-'
	'+'
	'*'
	'/'
	'%'
	'>'
	'<'
	'&'
	'|'
	'^'
	'('
	')'
	'['
	']'
	'{'
	'}'
]

line := s => (
	s := trimPrefix(s, Tab)
	s := trimPrefix(s, ' ')

	` TODO: parse next part `
)

` the lexer that follows is mostly a simplified
	port of ink/lexer.go, because the pretty-printer
	lexer doesn't need to discriminate between different
	structuring operators like expression/match lists, etc. `

stringLiteral := s => (
	` TODO: take until end quote `
)

blockComment := s => (
	` TODO: take until end of comment
		issue: we currently tokenize by line,
		how do we work across line breaks? `
)

lineComment := s => (
	` TODO: take until end of line `
)

identifier := s => (
	` TODO: take until non-identifier character `
)

symbol := s => (
	` TODO: "symbol" accounts for unary/binary operators & delimiters `
)
