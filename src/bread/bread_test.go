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
	"bread/swagger/client/canoe"
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

type fakeCanoeClient struct{}

func (c *fakeCanoeClient) UnlockTerraformProject(*canoe.UnlockTerraformProjectParams) (*canoe.UnlockTerraformProjectOK, error) {
	panic("not implemented")
}

func (c *fakeCanoeClient) PhoneAuthentication(*canoe.PhoneAuthenticationParams) (*canoe.PhoneAuthenticationOK, error) {
	panic("not implemented")
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
	auth, err := bread.NewAuthorizer(&bread.LDAPConfig{Addr: ldapAddr}, otpVerifier, &fakeCanoeClient{}, bread.ACL)
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
		t.Run(fmt.Sprintf("%s %s", tc.service, tc.method), func(t *testing.T) {
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
					t.Errorf("user %#v should not be authorized", tc.user)
				}
			} else {
				if tc.err == nil {
					t.Errorf("unexpected error: %s", err)
				} else if err.Error() != tc.err.Error() {
					t.Errorf("expected error message %#v, got %#v", tc.err.Error(), err.Error())
				}
			}
		})
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

type fakeSender struct{}

func (c *fakeSender) Send(_ context.Context, _ *operator.Source, _ string, _ *operator.Message) error {
	return nil
}

type fakeDeployer struct {
	builds  []bread.Build
	targets []*bread.DeployTarget
}

func (d *fakeDeployer) ListTargets(context.Context) ([]*bread.DeployTarget, error) {
	return d.targets, nil
}

func (d *fakeDeployer) ListBuilds(ctx context.Context, t *bread.DeployTarget, branch string) ([]bread.Build, error) {
	var builds []bread.Build
	if branch == "" {
		for _, b := range d.builds {
			if b.GetRepoURL() == "" || b.GetRepoURL() == t.Name {
				builds = append(builds, b)
			}
		}
		return builds, nil
	}
	for _, b := range d.builds {
		if (b.GetRepoURL() == "" || b.GetRepoURL() == t.Name) && b.GetBranch() == branch {
			builds = append(builds, b)
		}
	}
	return builds, nil
}

func (d *fakeDeployer) Deploy(ctx context.Context, s *operator.RequestSender, req *bread.DeployRequest) (*operator.Message, error) {
	return &operator.Message{
		Text: fmt.Sprintf(
			"deployed target=%s build=%s branch=%s",
			req.Target.Name,
			req.Build.GetID(),
			req.Build.GetBranch(),
		),
	}, nil
}

func TestDeploy(t *testing.T) {
	sender := &fakeSender{}
	deployer := &fakeDeployer{
		targets: []*bread.DeployTarget{
			{
				Name: "pardot",
			},
			{
				Name: "hal9000",
			},
		},
		builds: []bread.Build{
			&fakeBuild{
				ID:      "1",
				Branch:  "master",
				Created: time.Now(),
				RepoURL: "pardot",
			},
			&fakeBuild{
				ID:      "2",
				Branch:  "master",
				Created: time.Now(),
				RepoURL: "hal9000",
			},
			&fakeBuild{
				ID:      "old",
				Created: time.Now().Add(-36 * time.Hour),
				RepoURL: "pardot",
			},
		},
	}
	server := bread.NewDeployServer(sender, deployer, deployer, nil)
	for _, tc := range []struct {
		target string
		build  string
		branch string
		resp   string
		err    error
	}{
		{"pardot", "1", "", "target=pardot build=1 branch=master", nil},
		{"pardot", "", "", "target=pardot build=1 branch=master", nil},
		{"hal9000", "", "", "target=hal9000 build=2 branch=master", nil},
		{"hal9000", "", "boomtown", "", errors.New("No build found for branch boomtown of hal9000")},
		{"pardot", "old", "", "", errors.New("because it was created on")},
		{"bread", "1", "", "", errors.New("No such deployment target: bread")},
		{"pardot", "1", "master", "", errors.New(", but not both")},
		{"pardot", "", "not-found", "", errors.New("No build found for branch not-found")},
	} {
		t.Run(fmt.Sprintf("%s_%s_%s", tc.target, tc.build, tc.branch), func(t *testing.T) {
			resp, err := server.Trigger(context.Background(), &breadpb.TriggerRequest{
				Request: &operator.Request{Source: &operator.Source{}},
				Target:  tc.target,
				Build:   tc.build,
				Branch:  tc.branch,
			})
			if tc.err == nil {
				if err != nil {
					t.Errorf("expected no error bit got %s", err)
				} else if !strings.Contains(resp.Message, tc.resp) {
					t.Errorf("expected response message `%s` but got %s", tc.resp, resp.Message)
				}
			} else {
				if err == nil {
					t.Errorf("expect an error for but got none")
					if resp.Message != tc.resp {
						t.Errorf("expected response message `%s` for but got %s", tc.resp, resp.Message)
					}
				} else if !strings.Contains(err.Error(), tc.err.Error()) {
					t.Errorf("expected error to match `%s` but got: %s", tc.err, err)
				}
			}
		})
	}
}
