` inkfmt parser internals `

std := load('vendor/std')
str := load('vendor/str')

slice := std.slice
index := std.index
append := std.append

letter? := str.letter?
digit? := str.digit?
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
	doc := state.doc
	(sub := (i, literal) => (
		next := doc.(i) :: {
			'\\' -> sub(i + 2, literal + next + doc.(i + 1))
			guardToken -> lexRec({
				doc: doc
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
	doc := state.doc

	newlineIndex := (sub := i => doc.(i) :: {
		() -> ~1
		Newline -> i
		_ -> sub(i + 1)
	})(state.index + 2)

	newlineIndex :: {
		~1 -> lexRec({
			doc: doc
			index: len(state)
			tokens: state.tokens.len(state.tokens) :=
				slice(doc, state.index, len(doc))
		})
		_ -> lexRec({
			doc: doc
			index: newlineIndex + 1
			tokens: append(state.tokens, [
				slice(doc, state.index, newlineIndex)
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
	doc := state.doc

	` trim off starting space/tabs `
	state.index := indexNextSpace(doc, state.index)

	doc.(state.index) :: {
		() -> state
		Newline -> lexRec({
			doc: doc
			index: state.index + 1
			tokens: state.tokens.len(state.tokens) := Newline
		})
		'\'' -> lexStringLiteral(state)
		'`' -> doc.(state.index + 1) :: {
			'`' -> lexLineComment(state)
			_ -> lexBlockComment(state)
		}
		_ -> (
			` then, search for all symbols `
			matchedSymb := (sub := i => (
				symb := Symbols.(i)
				symb :: {
					() -> ()
					_ -> slice(doc, state.index, state.index + len(symb)) = symb :: {
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
					(sub := i => identifierCharacter?(doc.(i)) :: {
						false -> lexRec({
							doc: doc
							index: i
							tokens: state.tokens.len(state.tokens) :=
								slice(doc, state.index, i)
						})
						_ -> sub(i + 1)
					})(state.index + 1)
				)
				_ -> lexRec({
					doc: doc
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
