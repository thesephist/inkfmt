` inkfmt parser internals `

std := load('vendor/std')
str := load('vendor/str')

Newline := char(13)
Tab := char(9)

Symbols := [
	` we test for longer symbols first `
	'=>'
	':='
	'::'
	'->'
	'~'
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

` main exported function `
lex := s => (
	` TODO: fully tokenize document `

	s
)
