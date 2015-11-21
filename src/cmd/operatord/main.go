package main

import (
	"log"

	"github.com/sr/operator/src/operator"
)

func main() {
	if err := operator.Listen(); err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
}
