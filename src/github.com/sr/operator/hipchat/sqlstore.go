package operatorhipchat

import "database/sql"

type sqlStore struct {
	db *sql.DB
}

func newSQLStore(db *sql.DB) *sqlStore {
	return &sqlStore{db}
}

func (s *sqlStore) GetByOAuthID(id string) (*ClientCredentials, error) {
	var (
		oauthID     string
		oauthSecret string
	)
	row := s.db.QueryRow(`
		SELECT oauth_id, oauth_secret
		FROM hipchat_addon_installs
		WHERE oauth_id = ?`,
		id,
	)
	if err := row.Scan(&oauthID, &oauthSecret); err != nil {
		return nil, err
	}
	return &ClientCredentials{
		ID:     oauthID,
		Secret: oauthSecret,
	}, nil
}

func (s *sqlStore) GetByAddonID(id string) (*ClientCredentials, error) {
	var (
		oauthID     string
		oauthSecret string
	)
	row := s.db.QueryRow(`
		SELECT oauth_id, oauth_secret
		FROM hipchat_addon_installs
		WHERE addon_id = ?`,
		id,
	)
	if err := row.Scan(&oauthID, &oauthSecret); err != nil {
		return nil, err
	}
	return &ClientCredentials{
		ID:     oauthID,
		Secret: oauthSecret,
	}, nil
}

func (s *sqlStore) PutByAddonID(addonID string, client *ClientCredentials) error {
	_, err := s.db.Exec(`
		INSERT INTO hipchat_addon_installs (
			created_at,
			addon_id,
			oauth_id,
			oauth_secret
		)
		VALUES (NOW(), ?, ?, ?)`,
		addonID,
		client.ID,
		client.Secret,
	)
	return err
}
