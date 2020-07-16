` inkfmt parser internals `

std := load('vendor/std')
str := load('vendor/str')

f := std.format
slice := std.slice
append := std.append

letter? := str.letter?
digit? := str.digit?

index := str.index
hasPrefix? := str.hasPrefix?

Newline := char(10)
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
	','
	` not symbol per se, but should be parsed atomically `
	'_'
]

lexGuardTokenStringBlock := guardToken => state => (
	(sub := (i, literal) => (
		next := state.doc.(i) :: {
			'\\' -> sub(i + 2, literal + next + state.doc.(i + 1))
			guardToken -> {
				doc: slice(state.doc, i + 1, len(state.doc))
				tokens: state.tokens.len(state.tokens) :=
					guardToken + literal + guardToken
			}
			_ -> sub(i + 1, literal + next)
		}
	))(1, '')
)

lexStringLiteral := lexGuardTokenStringBlock('\'')
lexBlockComment := lexGuardTokenStringBlock('`')

lexLineComment := state => (
	newlineIndex := index(state.doc, Newline)
	index :: {
		~1 -> {
			doc: ''
			tokens: state.tokens.len(state.tokens) :=
				'``' + slice(state.doc, 2, len(state.doc))
		}
		_ -> {
			doc: slice(state.doc, newlineIndex + 1, len(state.doc))
			tokens: append(state.tokens, [
				'``' + slice(state.doc, 2, newlineIndex)
				Newline
			])
		}
	}
)

identifierCharacter? := c => c :: {
	() -> false
	_ -> letter?(c) | digit?(c) |  c = '?' | c = '!' | c = '@'
}

indexFirstNonWS := s => (sub := i => (
	s.(i) :: {
		() -> i - 1
		' ' -> sub(i + 1)
		Tab -> sub(i + 1)
		_ -> i
	}
))(0)

lexRec := state => (
	state.doc := slice(state.doc, indexFirstNonWS(state.doc), len(state.doc))

	state.doc.0 :: {
		() -> state
		Newline -> lexRec({
			doc: slice(state.doc, 1, len(state.doc))
			tokens: state.tokens.len(state.tokens) := Newline
		})
		'\'' -> lexRec(lexStringLiteral(state))
		'`' -> state.doc.1 :: {
			'`' -> lexRec(lexLineComment(state))
			_ -> lexRec(lexBlockComment(state))
		}
		_ -> (
			` then, search for all symbols `
			matchedSymb := (sub := i => (
				symb := Symbols.(i)
				symb :: {
					() -> ()
					_ -> slice(state.doc, 0, len(symb)) = symb :: {
						true -> symb
						false -> sub(i + 1)
					}
				}
			))(0)

			matchedSymb :: {
				() -> (
					` identifier, number, or true/false which can
						all be treated as identifiers for inkfmt:
						read until next non-identifier character `
						(sub := i => identifierCharacter?(state.doc.(i)) :: {
							false -> lexRec({
								doc: slice(state.doc, i, len(state.doc))
								tokens: state.tokens.len(state.tokens) :=
									slice(state.doc, 0, i)
							})
							_ -> sub(i + 1)
						})(1)
				)
				_ -> lexRec({
					doc: slice(state.doc, len(matchedSymb), len(state.doc))
					tokens: state.tokens.len(state.tokens) := matchedSymb
				})
			}
		)
	}
)

` main exported function `
lex := s => (
	state := lexRec({
		` TODO: probably should be passing i scanning thru doc,
			instead of copying slices of doc around `
		` TODO: decompose this struct into two arguments that are passed
			around separately `
		doc: s
		tokens: []
    })

	state.tokens
)
