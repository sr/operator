package operatorhipchat

import (
	"database/sql"
)

// TODO(sr) Move this to the DB
const hostname = "hipchat.dev.pardot.com"

type sqlStore struct {
	db *sql.DB
}

func newSQLStore(db *sql.DB) *sqlStore {
	return &sqlStore{db}
}

func (s *sqlStore) Create(client *ClientCredentials) error {
	_, err := s.db.Exec(`
		INSERT INTO hipchat_client_credentials (
			created_at,
			oauth_id,
			oauth_secret
		)
		VALUES (NOW(), ?, ?)`,
		client.ID,
		client.Secret,
	)
	return err
}

func (s *sqlStore) GetByOAuthID(id string) (ClientConfiger, error) {
	var (
		oauthID     string
		oauthSecret string
	)
	row := s.db.QueryRow(`
		SELECT oauth_id, oauth_secret
		FROM hipchat_client_credentials
		WHERE oauth_id = ?`,
		id,
	)
	if err := row.Scan(&oauthID, &oauthSecret); err != nil {
		return nil, err
	}
	return &ClientConfig{
		Hostname: hostname,
		Credentials: &ClientCredentials{
			ID:     oauthID,
			Secret: oauthSecret,
		},
	}, nil
}
