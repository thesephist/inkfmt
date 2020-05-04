` syntax tree tests `

` bootstrap test harness `
s := (load('../vendor/suite').suite)(
	'Syntax tree tests'
)
m := s.mark
t := s.test
