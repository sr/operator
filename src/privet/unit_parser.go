package privet

import (
	"bufio"
	"encoding/json"
	"io"
)

type UnitParser struct {
	r io.Reader
	s *bufio.Scanner
}

func NewUnitParser(r io.Reader) *UnitParser {
	return &UnitParser{
		r: r,
		s: bufio.NewScanner(r),
	}
}

// Next decodes the next unit or (nil, nil) if no more units are available
func (p *UnitParser) Next() (*Unit, error) {
	var unit Unit

	if !p.s.Scan() {
		// EOF
		return nil, nil
	}
	if err := p.s.Err(); err != nil {
		return nil, err
	}

	line := p.s.Bytes()
	if err := json.Unmarshal(line, &unit); err != nil {
		return nil, err
	}

	return &unit, nil
}
