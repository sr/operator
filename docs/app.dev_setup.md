# Canoe on App.dev


#### Deploy User on Github
We need to setup a deploy user on Github that has read-only access to only repos that it needs to pull, etc. Create some SSH keys and put them on the servers where deploys need to occur. _Can we put the SSH keys in a chef data bag?_

Currently, we have an odd mechanism of using deploy keys to pull the projects. However, this has turned out to be not as ideal as I had initially thought. Biggest \#trust thing is that you can't make a deploy key be read-only, which you'd think was obvious on the Github side. They are also one-for-one with the repos, so we have to have special code in the sync scripts to use these silly keys everywhere and it's a PITA.

## App.dev
`jump.dev` currently runs `canoe` and `ship-it` for the app.dev environment. Here are most of the related things to have these run.

### Prerequisites 
- Apache
- MySQL
- Ruby & RVM
- Git

### Deploy User
We currently use a deploy user to run the canoe code and also run the sync scripts. Here are the things in his/her `$HOME`.

- Setup ssh keys _(from a data bag?)_
- Dot files with configuration for `canoe` - _(from a data bag or generated?)_
- `$HOME/repo/` - Where `canoe` is checked out and `capistrano` commands are executed

### Directory Structures
Needed directories for the different pieces of the puzzle.

- `/opt/sync/composer_cache` - Used by composer during the sync process
- `/opt/sync/github-symfony` - The checkout of the `symfony` project
- `/opt/sync/github-pi` - The checkout of the `pardot` project
- `/opt/sync/github-thumbs` - The checkout of the `pithumbs` project
- `/opt/sync/prod` - The checkout of the `sync_scripts` project
- `/var/canoe` - This is where `capistrano` pushes the code. Under it you'll find a current symlink, a shared folder and a releases folder. `capistrano` currently manages this. I'm not sure if we want/can continue this in the future.

### Apache Setup
Normal apache install followed by install the `passenger` gem. This will then require that the `passenger` mod be setup in `/etc/httpd/conf.d/passenger.conf`. It should look like the following, except with the path to where the `passenger` gem was installed by the given `ruby`.

	LoadModule passenger_module /usr/local/rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/passenger-4.0.23/buildout/apache2/mod_passenger.so
	PassengerRoot /usr/local/rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/passenger-4.0.23
	PassengerDefaultRuby /usr/local/rbenv/versions/2.0.0-p247/bin/ruby

Also needed will be the necessary `VirtualHost` config in `/etc/httpd/conf.d/canoe.conf` and looks like:

	<VirtualHost *:80>
	  ServerName canoe.dev.pardot.com
	  DocumentRoot /var/canoe/current/public

	  ErrorLog  /var/canoe/shared/log/apache_error.log
	  CustomLog /var/canoe/shared/log/apache_custom.log common

	  <Directory /var/canoe/current/public>
	    AllowOverride all
	    # MultiViews must be turned off.
	    Options -MultiViews
	  </Directory>
	</VirtualHost>

### MySQL Setup
Normal MySQL setup is required then a database created for `canoe`. The settings for the database should be placed in the dot file in the deploy user's directory so they can be linked by the `capistrano` deployment.

### Canoe Setup
Things we need to have setup for `canoe`. Set these in the dot file in the deploy user's directory.

- `ENV["DATABASE_URL"]` = MySQL database "URL". eg: `mysql2://user:password@host:3306/databasename`
- `ENV["SESSION_SECRET"]` = Generate with any ole `rails` project, kinda need it to be different in each environment for \#trust
- `ENV["API_AUTH_TOKEN"]` = The API auth token for this environment
- `ENV["GOOGLE_CLIENT_ID"]` = Google OAuth client ID
- `ENV["GOOGLE_SECRET"]` = Google OAuth secret