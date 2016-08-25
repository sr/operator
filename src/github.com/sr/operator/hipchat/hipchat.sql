CREATE TABLE IF NOT EXISTS hipchat_client_credentials (
	id integer PRIMARY KEY NOT NULL AUTO_INCREMENT,
	created_at datetime NOT NULL,
	deleted_at datetime NULL,
	oauth_id varchar(255) NOT NULL,
	oauth_secret varchar(255) NOT NULL,
	UNIQUE(oauth_id),
	UNIQUE(oauth_secret)
);
