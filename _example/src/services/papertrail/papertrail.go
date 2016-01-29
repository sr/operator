package papertrail

import gopapertrail "github.com/sourcegraph/go-papertrail/papertrail"

type Env struct {
	APIToken string `env:"PAPERTRAIL_API_TOKEN,required"`
}

func NewAPIServer(env *Env) (PapertrailServiceServer, error) {
	token := &gopapertrail.TokenTransport{Token: env.APIToken}
	client := gopapertrail.NewClient(token.Client())
	return newAPIServer(client), nil
}
