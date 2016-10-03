package bread_test

import (
	"bread"
	"errors"
	"flag"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/go-ldap/ldap"
	"github.com/sr/operator"
	"golang.org/x/net/context"

	"bread/pb"
)

var ldapEnabled bool

func init() {
	flag.BoolVar(&ldapEnabled, "ldap", false, "")
	flag.Parse()
}

type fakeOTPVerifier struct {
	ok bool
}

func (v *fakeOTPVerifier) Verify(otp string) error {
	if !v.ok {
		return errors.New("boomtown")
	}
	return nil
}

func (v *fakeOTPVerifier) fail() {
	v.ok = false
}

func TestAuthorizer(t *testing.T) {
	var host, port string
	if v, ok := os.LookupEnv("LDAP_PORT_389_TCP_ADDR"); ok {
		host = v
	}
	if v, ok := os.LookupEnv("LDAP_PORT_389_TCP_PORT"); ok {
		port = v
	}
	if host == "" || port == "" {
		if ldapEnabled {
			t.Fatal("ldap flag set but LDAP_PORT_389_TCP_{ADDR,PORT} not set")
		}
		t.Skip("ldap flag set but LDAP_PORT_389_TCP_{ADDR,PORT} not set")
	}
	ldapAddr := fmt.Sprintf("%s:%s", host, port)
	var (
		i    int
		conn *ldap.Conn
		err  error
	)
	for {
		conn, err = ldap.Dial("tcp", ldapAddr)
		if err != nil {
			continue
		}
		err = conn.Bind("", "")
		if err == nil {
			break
		}
		if i >= 500 {
			t.Fatal(err)
		}
		time.Sleep(1 * time.Millisecond)
		i = i + 1
	}
	defer conn.Close()
	otpVerifier := &fakeOTPVerifier{true}
	auth, err := bread.NewAuthorizer(&bread.LDAPConfig{Addr: ldapAddr}, otpVerifier, bread.ACL)
	if err != nil {
		t.Fatal(err)
	}
	swe := "srozet@salesforce.com" // yubiKeyId: ccccccdluefe
	noYubiKey := "mlockhart@salesforce.com"
	unknown := "boom@gmail.com"
	validOTP := "ccccccdluefelbvvgdbehnlutdbbnnfgggvgbbjcdltu"
	for _, tc := range []struct {
		user    string
		service string
		method  string
		otp     string
		otpOK   bool
		err     error
	}{
		{swe, "bread.Ping", "Ping", "", true, nil},
		{swe, "bread.Ping", "PingPong", "", true, nil},
		{swe, "bread.Ping", "Whoami", "", true, nil},
		{"", "bread.Ping", "Ping", "", true, errors.New("unable to authorize request without an user email")},
		{swe, "bread.Ping", "Pong", "", true, errors.New("no ACL entry found for service `bread.Ping Pong`")},
		{unknown, "bread.Ping", "Ping", "", true, errors.New("no user matching email `boom@gmail.com`")},
		{swe, "bread.Ping", "Otp", validOTP, true, nil},
		{noYubiKey, "bread.Ping", "Otp", validOTP, true, fmt.Errorf("LDAP user `%s` does not have a Yubikey ID", noYubiKey)},
		{swe, "bread.Ping", "Otp", "", true, errors.New("service `bread.Ping Otp` requires a Yubikey OTP")},
		{swe, "bread.Ping", "Otp", validOTP, false, errors.New("could not verify Yubikey OTP: boomtown")},
		{swe, "bread.Ping", "Otp", "garbage", true, errors.New("could not verify Yubikey OTP: boomtown")},
	} {
		if !tc.otpOK {
			otpVerifier.fail()
		}
		err := auth.Authorize(context.Background(), &operator.Request{
			Call: &operator.Call{
				Service: tc.service,
				Method:  tc.method,
			},
			Otp: tc.otp,
			Source: &operator.Source{
				Type: operator.SourceType_HUBOT,
				User: &operator.User{
					Email: tc.user,
				},
			},
		})
		if err == nil {
			if tc.err != nil {
				t.Errorf("user %#v should not be authorized to request %s.%s", tc.user, tc.service, tc.method)
			}
		} else {
			if tc.err == nil {
				t.Fatalf("unexpected error: %s", err)
			}
			if err.Error() != tc.err.Error() {
				t.Errorf("expected error message %#v, got %#v", tc.err.Error(), err.Error())
			}
		}
	}
}

type fakeBuild struct {
	ID          string
	URL         string
	ArtifactURL string
	Branch      string
	SHA         string
	RepoURL     string
	Created     time.Time
}

func (b *fakeBuild) GetID() string {
	return b.ID
}

func (b *fakeBuild) GetURL() string {
	return b.URL
}

func (b *fakeBuild) GetArtifactURL() string {
	return b.ArtifactURL
}

func (b *fakeBuild) GetBranch() string {
	return b.Branch
}

func (b *fakeBuild) GetSHA() string {
	return b.SHA
}

func (b *fakeBuild) GetShortSHA() string {
	if len(b.SHA) <= 7 {
		return b.SHA
	}
	return b.SHA[0:7]
}

func (b *fakeBuild) GetRepoURL() string {
	return b.RepoURL
}

func (b *fakeBuild) GetCreated() time.Time {
	return b.Created
}

type fakeAuthorizer struct {
	err error
}

func (a *fakeAuthorizer) Authorize(context.Context, *operator.Request) error {
	return a.err
}

type fakeInstrumenter struct {
	events []*operator.Event
}

func (i *fakeInstrumenter) Instrument(ev *operator.Event) {
	i.events = append(i.events, ev)
}

func (i *fakeInstrumenter) pop() (ev *operator.Event) {
	if len(i.events) == 0 {
		return nil
	}
	ev, i.events = i.events[len(i.events)-1], i.events[:len(i.events)-1]
	return ev
}

type fakeSender struct{}

func (c *fakeSender) Send(_ context.Context, _ *operator.Source, _ string, _ *operator.Message) error {
	return nil
}

type fakeDeployer struct {
	builds         []bread.Build
	targets        []*bread.DeployTarget
	deployResponse *operator.Message
}

func (d *fakeDeployer) ListTargets(context.Context) ([]*bread.DeployTarget, error) {
	return d.targets, nil
}

func (d *fakeDeployer) ListBuilds(context.Context, *bread.DeployTarget, string) ([]bread.Build, error) {
	return d.builds, nil
}

func (d *fakeDeployer) Deploy(context.Context, *operator.RequestSender, *bread.DeployRequest) (*operator.Message, error) {
	return d.deployResponse, nil
}

func TestDeploy(t *testing.T) {
	sender := &fakeSender{}
	deployer := &fakeDeployer{
		targets: []*bread.DeployTarget{
			{
				Name: "pardot",
			},
		},
		builds: []bread.Build{
			&fakeBuild{
				ID:      "1",
				Created: time.Now(),
			},
			&fakeBuild{
				ID:      "old",
				Created: time.Now().Add(-36 * time.Hour),
			},
		},
		deployResponse: &operator.Message{
			Text: "deployed",
		},
	}
	server := bread.NewDeployServer(sender, deployer, deployer, nil)
	for _, tc := range []struct {
		target string
		build  string
		resp   string
		err    error
	}{
		{"pardot", "1", "deployed", nil},
		{"pardot", "old", "", errors.New("refusing to deploy build")},
		{"bread", "1", "", errors.New("No such deployment target: bread")},
	} {
		resp, err := server.Trigger(context.Background(), &breadpb.TriggerRequest{
			Request: &operator.Request{Source: &operator.Source{}},
			Target:  tc.target,
			Build:   tc.build,
		})
		if tc.err == nil {
			if err != nil {
				t.Fatalf("expected no error for target=%s build=%s, got: %s", tc.target, tc.build, err)
			}
			if resp.Message != tc.resp {
				t.Fatalf("expected response message `%s` for target=%s build=%s but got: %#v", tc.resp, tc.target, tc.build, resp.Message)
			}
		} else {
			if err == nil {
				t.Errorf("expect an error for target=%s build=%s but got none", tc.target, tc.build)
				if resp.Message != tc.resp {
					t.Fatalf("expected response message `%s` for target=%s build=%s but got: %#v", tc.resp, tc.target, tc.build, resp.Message)
				}
			} else if !strings.Contains(err.Error(), tc.err.Error()) {
				t.Errorf("expected error for target=%s build=%s to match `%s` but got: %s", tc.target, tc.build, tc.err, err)
			}
		}
	}
}
