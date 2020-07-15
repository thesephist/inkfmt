` inkfmt: token list renderer `

std := load('vendor/std')

map := std.map
cat := std.cat

Newline := char(10)

render := tokens => (
	cat(tokens, ' ')
)
