CREATE TABLE IF NOT EXISTS hipchat_addon_installs (
	id integer PRIMARY KEY NOT NULL,
	created_at datetime NOT NULL,
	deleted_at datetime NULL,
	addon_id varchar(255) NOT NULL,
	oauth_id varchar(255) NOT NULL,
	oauth_secret varchar(255) NOT NULL,
	UNIQUE(addon_id),
	UNIQUE(oauth_id),
	UNIQUE(oauth_secret)
);
