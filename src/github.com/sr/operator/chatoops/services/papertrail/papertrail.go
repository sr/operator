package papertrail

import gopapertrail "github.com/sourcegraph/go-papertrail/papertrail"

func NewAPIServer(config *PapertrailServiceConfig) (PapertrailServiceServer, error) {
	token := &gopapertrail.TokenTransport{Token: config.ApiKey}
	client := gopapertrail.NewClient(token.Client())
	return newAPIServer(client), nil
}
