` a test document `

a := 1
b := 'hello'
c := {
	d: 4
	`` a list of three ints
	e: [5, 6, 7]
	f: {
		first: 1,
		second: 2,
		third: 3,
	}
	Pi: 3.141592 `` testing parsing decimals
}

func := (x, y) => x + y * 10

g := (a, b, c, d, e, f) =>
	a + b + c + d +
	e + f

log(f('{{ 0 }} --> {{ 1 }}'
	[a, b]))
readFile('/dev/stdin', data => (
	doSomethingWith(data)
))

` copy of std.log function
	and a description in a multiline block comment `
Newline := char(~~10)
log := x => (
	out(string(x) + Newline)
)
