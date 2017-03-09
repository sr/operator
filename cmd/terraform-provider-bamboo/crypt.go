package main

import (
	"crypto/sha256"
	"encoding/hex"

	"github.com/hashicorp/terraform/helper/schema"
)

var _ schema.SchemaStateFunc = hashPassword

// hashPassword hashes a password and makes it more suitable to store in
// Terraform state
func hashPassword(s interface{}) string {
	hash := sha256.New()
	// hash.Write "never returns an error."
	_, _ = hash.Write([]byte(s.(string)))
	return hex.EncodeToString(hash.Sum(nil))
}
