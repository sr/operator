package privet

import (
	"bufio"
	"encoding/json"
	"io"
)

const (
	// MaxUnitSize corresponds to ARG_MAX on Linux
	MaxUnitSize = 2621440
)

type UnitParser struct {
	r io.Reader
	s *bufio.Scanner
}

func NewUnitParser(r io.Reader) *UnitParser {
	s := bufio.NewScanner(r)
	s.Buffer(make([]byte, bufio.MaxScanTokenSize), MaxUnitSize)

	return &UnitParser{
		r: r,
		s: s,
	}
}

// Next decodes the next unit or (nil, nil) if no more units are available
func (p *UnitParser) Next() (*Unit, error) {
	var unit Unit

	if !p.s.Scan() {
		// Either an error or EOF (note p.s.Err() is nil in the case of EOF)
		return nil, p.s.Err()
	}

	line := p.s.Bytes()
	if err := json.Unmarshal(line, &unit); err != nil {
		return nil, err
	}

	return &unit, nil
}
