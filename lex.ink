` inkfmt parser internals `

std := load('vendor/std')
str := load('vendor/str')

log := std.log
f := std.format
slice := std.slice
index := std.index
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
			guardToken -> lexRec({
				doc: state.doc
				index: i + 1
				tokens: state.tokens.len(state.tokens) :=
					guardToken + literal + guardToken
			})
			_ -> sub(i + 1, literal + next)
		}
	))(state.index + 1, '')
)

lexStringLiteral := lexGuardTokenStringBlock('\'')
lexBlockComment := lexGuardTokenStringBlock('`')

lexLineComment := state => (
	newlineIndex := (sub := i => state.doc.(i) :: {
		() -> ~1
		Newline -> i
		_ -> sub(i + 1)
	})(state.index + 2)
	newlineIndex :: {
		~1 -> lexRec({
			doc: state.doc
			index: len(state)
			tokens: state.tokens.len(state.tokens) :=
				slice(state.doc, state.index, len(state.doc))
		})
		_ -> lexRec({
			doc: state.doc
			index: newlineIndex + 1
			tokens: append(state.tokens, [
				slice(state.doc, state.index, newlineIndex)
				Newline
			])
		})
	}
)

identifierCharacter? := c => c :: {
	() -> false
	_ -> letter?(c) | digit?(c) | c = '?' | c = '!' | c = '@'
}

indexNextSpace := (doc, index) => (sub := i => (
	doc.(i) :: {
		' ' -> sub(i + 1)
		Tab -> sub(i + 1)
		_ -> i
	}
))(index)

lexRec := state => (
	state.index := indexNextSpace(state.doc, state.index)

	state.doc.(state.index) :: {
		() -> state
		Newline -> lexRec({
			doc: state.doc
			index: state.index + 1
			tokens: state.tokens.len(state.tokens) := Newline
		})
		'\'' -> lexStringLiteral(state)
		'`' -> state.doc.(state.index + 1) :: {
			'`' -> lexLineComment(state)
			_ -> lexBlockComment(state)
		}
		_ -> (
			` then, search for all symbols `
			matchedSymb := (sub := i => (
				symb := Symbols.(i)
				symb :: {
					() -> ()
					_ -> slice(state.doc, state.index, state.index + len(symb)) = symb :: {
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
							doc: state.doc
							index: i
							tokens: state.tokens.len(state.tokens) :=
								slice(state.doc, state.index, i)
						})
						_ -> sub(i + 1)
					})(state.index + 1)
				)
				_ -> lexRec({
					doc: state.doc
					index: state.index + len(matchedSymb)
					tokens: state.tokens.len(state.tokens) := matchedSymb
				})
			}
		)
	}
)

lex := s => (
	state := {
		doc: s
		index: 0
		tokens: []
	}

	hasPrefix?(s, '#!/') :: {
		true -> (
			state.index := index(s, Newline)
			state.tokens := [slice(s, 0, index(s, Newline))]
		)
	}

	lexRec(state).tokens
)
