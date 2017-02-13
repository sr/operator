package operatorhipchat

import (
	"database/sql"
	"errors"
)

type sqlStore struct {
	db       *sql.DB
	hostname string
}

func newSQLStore(db *sql.DB, hostname string) *sqlStore {
	return &sqlStore{db, hostname}
}

func (s *sqlStore) Create(client *ClientCredentials) error {
	if client.ID == "" || client.Secret == "" {
		return errors.New("client ID and/or secret is null")
	}
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

func (s *sqlStore) GetByOAuthID(id string) (Clienter, error) {
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
		Hostname: s.hostname,
		Credentials: &ClientCredentials{
			ID:     oauthID,
			Secret: oauthSecret,
		},
	}, nil
}
