package privet_test

import (
	"bytes"
	"privet"
	"testing"
	"time"
)

func TestParseJunitResults(t *testing.T) {
	junitResultStr := `
<?xml version="1.0" encoding="UTF-8"?>
<testsuites>
  <testsuite name="privet" tests="28" assertions="79" failures="0" errors="0" time="21">
    <testsuite name="piUserTest" file="/app/test/piUserTest.php" tests="15" assertions="40" failures="0" errors="0" time="21">
      <testcase name="testSendActivationEmail" class="piUserTest" file="/app/test/piUserTest.php" line="18" assertions="6" time="19"/>
      <testsuite name="piUserTest::test_setIsArchived" tests="6" assertions="18" failures="0" errors="0" time="2">
	<testcase name="test_setIsArchived with data set #0" assertions="3" time="2"/>
      </testsuite>
    </testsuite>
  </testsuite>
</testsuites>
`
	results, err := privet.ParseJunitResult(bytes.NewBufferString(junitResultStr))
	if err != nil {
		t.Fatal(err)
	}

	if len(results) != 1 {
		t.Errorf("len(results): expected %d, got %d", 1, len(results))
	}
	if results["/app/test/piUserTest.php"].Name != "piUserTest" {
		t.Errorf("results[/app/test/piUserTest.php].Name: expected %s, got %s", "piUserTest", results["/app/test/piUserTest.php"].Name)
	}
	if results["/app/test/piUserTest.php"].File != "/app/test/piUserTest.php" {
		t.Errorf("results[/app/test/piUserTest.php].File: expected %s, got %s", "/app/test/piUserTest.php", results["/app/test/piUserTest.php"].File)
	}
	if results["/app/test/piUserTest.php"].Duration != 21*time.Second {
		t.Errorf("results[/app/test/piUserTest.php].Duration: expected %s, got %s", 21*time.Second, results["/app/test/piUserTest.php"].Duration)
	}
	if len(results["/app/test/piUserTest.php"].TestCases) != 2 {
		t.Errorf("len(results[/app/test/piUserTest.php].TestCases): expected %d, got %d", 2, len(results["/app/test/piUserTest.php"].TestCases))
	}
}

func TestPopulateFingerprintsFromShasumsFile(t *testing.T) {
	shasumsStr := `b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c /app/test1.php`
	results := privet.TestRunResults{
		"/app/test1.php": {
			File: "/app/test1.php",
		},
	}

	err := privet.PopulateFingerprintsFromShasumsFile(results, bytes.NewBufferString(shasumsStr))
	if err != nil {
		t.Fatal(err)
	}

	if results["/app/test1.php"].Fingerprint != "b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c" {
		t.Errorf("expected fingerprint to be populated from shasums file, but was %s", results["/app/test1.php"].Fingerprint)
	}
}
