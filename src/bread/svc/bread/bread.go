package bread

import (
	"net/http"
	"net/url"
	"strconv"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ecr"
	"github.com/aws/aws-sdk-go/service/ecs"
)

type BambooTransport struct {
	Username string
	Password string
}

func NewAPIServer(config *BreadConfig) (BreadServer, error) {
	i, err := strconv.Atoi(config.DeployTimeout)
	if err != nil {
		return nil, err
	}
	bamboo := &BambooTransport{
		Username: config.BambooUsername,
		Password: config.BambooPassword,
	}
	u, err := url.Parse(config.BambooUrl)
	if err != nil {
		return nil, err
	}
	client := session.New(&aws.Config{Region: aws.String(config.AwsRegion)})
	return newAPIServer(
		ecs.New(client),
		ecr.New(client),
		bamboo.Client(),
		u,
		map[string]string{
			"canoe":   "canoe_production",
			"hal9000": "hal9000_production",
		},
		config.CanoeEcsService,
		i,
	)
}

func (t BambooTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	req.SetBasicAuth(t.Username, t.Password)
	req.Header.Set("Accept", "application/json")
	return http.DefaultTransport.RoundTrip(req)
}

func (t *BambooTransport) Client() *http.Client {
	return &http.Client{Transport: t}
}
