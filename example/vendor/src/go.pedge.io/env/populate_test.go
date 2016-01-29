package env

import (
	"bytes"
	"io"
	"io/ioutil"
	"os"
	"reflect"
	"strings"
	"testing"
)

type subEnv struct {
	SubEnvRequiredString        string `env:"SUB_ENV_REQUIRED_STRING,required"`
	SubEnvOptionalString        string `env:"SUB_ENV_OPTIONAL_STRING"`
	SubEnvOptionalUint16Default uint16 `env:"SUB_ENV_OPTIONAL_UINT16_DEFAULT,default=1024"`
}

type testEnv struct {
	RequiredString string `env:"REQUIRED_STRING,required"`
	OptionalString string `env:"OPTIONAL_STRING"`
	OptionalInt    int    `env:"OPTIONAL_INT"`
	OptionalBool   bool   `env:"OPTIONAL_BOOL"`
	SubEnv         subEnv
	Struct         struct {
		StructOptionalInt int `env:"STRUCT_OPTIONAL_INT"`
	}
	OptionalStringDefault string `env:"OPTIONAL_STRING_DEFAULT,default=foo"`
}

// TODO(pedge): if tests are run in parallel, this is affecting global state

func TestBasic(t *testing.T) {
	runTest(
		t,
		func(t *testing.T, testEnv *testEnv) {
			checkEqual(t, "foo", testEnv.RequiredString)
			checkEqual(t, "", testEnv.OptionalString)
			checkEqual(t, 1234, testEnv.OptionalInt)
			checkEqual(t, true, testEnv.OptionalBool)
			checkEqual(t, "bar", testEnv.SubEnv.SubEnvRequiredString)
			checkEqual(t, "baz", testEnv.SubEnv.SubEnvOptionalString)
			checkEqual(t, uint16(1024), testEnv.SubEnv.SubEnvOptionalUint16Default)
			checkEqual(t, 5678, testEnv.Struct.StructOptionalInt)
			checkEqual(t, "foo", testEnv.OptionalStringDefault)
		},
		map[string]string{
			"REQUIRED_STRING":                 "foo",
			"OPTIONAL_INT":                    "1234",
			"OPTIONAL_BOOL":                   "T",
			"SUB_ENV_REQUIRED_STRING":         "bar",
			"SUB_ENV_OPTIONAL_STRING":         "baz",
			"SUB_ENV_OPTIONAL_STRING_DEFAULT": "baz",
			"STRUCT_OPTIONAL_INT":             "5678",
		},
	)
}

func TestMissing(t *testing.T) {
	runErrorTest(t, envKeyNotSetWhenRequiredErr, map[string]string{"REQUIRED_STRING": "foo"})
	runErrorTest(t, envKeyNotSetWhenRequiredErr, map[string]string{"SUB_ENV_REQUIRED_STRING": "bar"})
}

func TestCannotParse(t *testing.T) {
	runErrorTest(
		t,
		cannotParseErr,
		map[string]string{
			"REQUIRED_STRING":         "foo",
			"SUB_ENV_REQUIRED_STRING": "bar",
			"OPTIONAL_INT":            "abc",
		},
	)
}

func runTest(t *testing.T, f func(*testing.T, *testEnv), env map[string]string, envFiles ...string) {
	runTestLong(t, "", f, env, envFiles...)
}

func runErrorTest(t *testing.T, expectedError string, env map[string]string, envFiles ...string) {
	runTestLong(t, expectedError, nil, env, envFiles...)
}

func runTestLong(t *testing.T, expectedError string, f func(*testing.T, *testEnv), env map[string]string, envFiles ...string) {
	decoders := make([]Decoder, len(envFiles))
	for i, envFile := range envFiles {
		reader := getTestReader(t, envFile)
		if strings.HasSuffix(envFile, ".env") {
			decoders[i] = newEnvFileDecoder(reader)
		} else if strings.HasSuffix(envFile, ".json") {
			decoders[i] = newJSONDecoder(reader)
		} else {
			t.Fatalf("unknown suffix for file name: %s", envFile)
		}
	}
	originalEnv := make(map[string]string)
	for key, value := range env {
		originalEnv[key] = os.Getenv(key)
		_ = os.Setenv(key, value)
	}
	defer func() {
		for key, value := range originalEnv {
			_ = os.Setenv(key, value)
		}
	}()
	testEnv := &testEnv{}
	err := Populate(
		testEnv,
		decoders...,
	)
	if err != nil && expectedError == "" {
		t.Error(err)
		return
	}
	if err != nil && expectedError != "" {
		if !strings.HasPrefix(err.Error(), expectedError) {
			t.Errorf("expected error type %s, got error %s", expectedError, err.Error())
			return
		}
	}
	if err == nil && expectedError != "" {
		t.Errorf("expected error %s, but no error", expectedError)
		return
	}
	if f != nil {
		f(t, testEnv)
	}
}

func getTestReader(t *testing.T, filePath string) io.Reader {
	file, err := os.Open(filePath)
	if err != nil {
		t.Fatal(err)
	}
	data, err := ioutil.ReadAll(file)
	if err != nil {
		if err := file.Close(); err != nil {
			t.Error(err)
		}
		t.Fatal(err)
	}
	if err := file.Close(); err != nil {
		t.Fatal(err)
	}
	return bytes.NewBuffer(data)
}

func checkEqual(t *testing.T, expected interface{}, actual interface{}) {
	if !reflect.DeepEqual(expected, actual) {
		// TODO(pedge): fatals out when need to call defer to reset env
		t.Fatalf("expected %v, got %v", expected, actual)
	}
}
