Instructions for Installing Canoe
=================================

This process should allow us to configure and deploy Canoe to a new server.

------------------------------------------------------------------------------

Ruby
====

We rely on Ruby >= v2.0, which isn't readily available (sadly) from a lot of package repos.
What follows is the *hard* way to do it (ie: by hand).


1. __Install rbenv__ *(v0.4.0 @ time of writing - substitute as appropriate below)*

    - Clone the git repo in /usr/local :

        `sudo git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv-0.4.0`

    - Create a symlink for /usr/local/rbenv :

        `sudo ln -s /usr/local/rbenv-0.4.0 /usr/local/rbenv`

    - Check out the v0.4.0 tag

        `cd /usr/local/rbenv; sudo checkout tags/v0.4.0 -b v0.4.0`

    - Add rbenv to your ENV in your .bash_profile

            export RBENV_ROOT=/usr/local/rbenv
            export PATH=$RBENV_ROOT/bin:$PATH:$HOME/bin
            eval "$(rbenv init -)"

    - Add group for rbenv and add appropriate users to it.

        `sudo groupadd rbenv`

        - Add these people (`pi,sv,sp,wheel,apache,root,deploy`) to it (and others, as needed):

            `sudo vim /etc/group`

    - Use this group for the rbenv directory

        `sudo chown -R root:rbenv /usr/local/rbenv-0.4.0/`

    - Make sure the group can write to the folder

        `sudo chmod -R g+w /usr/local/rbenv-v0.4.0`

    - Log out and back in to pick up group and have profile changes fire off...

        - Double check that the `rbenv init` worked by checking /usr/local/rbenv for shim and versions directories.

2. __Install ruby-build__

    - Create plugins directory for rbenv

        `cd /usr/local/rbenv; sudo mkdir plugins`

        - Fix permissions and what-not

            `sudo chown root:rbenv plugins; sudo chmod 775 plugins`

    - Clone git repo into plugins

        `cd plugins; git clone https://github.com/sstephenson/ruby-build.git`

    - Confirm all is well

        `rbenv install -l`

        *(Should display long list of ruby versions)*

3. __Install Ruby 2.0__ *(2.0.0-p247 @ time of writing)*

    `rbenv install 2.0.0-p247`

    - Grab a coffee... wait... wait more...

    - */me drums fingers on the table*

    - When it completes, set the global version to this:

        `rbenv global 2.0.0-p247`

    - Confirm

        `ruby -v`

4. __Install Necessary Gems__

        gem install bunder
        gem install capistrano --version=2.15.5   # until we upgrade to 3.0.x
        rbenv rehash

------------------------------------------------------------------------------

MySQL
=====

Canoe uses MySQL as the backing database. __NOTE: MySQL may already be installed__

1. Install yum package for mysql and mysql-devel (needed for ruby extensions to build)

    `sudo yum install mysql mysql-devel mysql-server`

2. Start our server

    `sudo service mysqld start`

3. Create our canoe database

    `mysqladmin -uroot -p create canoe_staging`

4. Grant access to our canoe user

        mysql -uroot -p
        ...
        grant all on canoe_staging.* to 'canoe'@'localhost' identified by '<sekret_password_here>';

    _Intentionally leaving password off. It can be found in the env vars file discussed below. #trust_

------------------------------------------------------------------------------

Canoe
=====

We use a deploy key to pull the code (read-only) from github.

1. Get appropriate SSH keys (I have them, should they be needed) and add them to your .ssh directory.
To avoid some github/ssh mess, I also symlink id_rsa to canoe_id_rsa and id_rsa.pub to canoe_id_rsa.pub. YMMV

2. Checkout git repo.

        mkdir -p ~/repo
        cd ~/repo
        git clone git@github.com:Pardot/canoe.git

3. Create our deploy destination

        sudo mkdir -p /var/canoe
        sudo chown -R sv:wheel /var/canoe
        sudo chmod g+w /var/canoe

4. Copy over ENV variables file (I have a copy, should they be needed) to their appropriate spot and link them so the app can find them on launch.
    _Intentionally leaving this a bit vague... #trust_

5. We'll need

5. Fire up Capistrano

        cd ~/repo/canoe
        cap deploy:setup
        sudo chown -R sv:wheel /var/canoe # not sure why capistrano doesn't do this...
        cap deploy

------------------------------------------------------------------------------

Apache
======

We need to setup the Ruby gem `passenger` and a virtual host.

1. __Install Passenger__

    - Install gem

            gem install passenger
            rbenv rehash

    - Build and install the passenger Apache mod

        `sudo passenger-install-apache2-module`

        - Add module load instructions to passenger.conf

            `sudo vim /etc/httpd/conf.d/passenger.conf`

            It should look something like:

                  LoadModule passenger_module /usr/local/rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/passenger-4.0.23/buildout/apache2/mod_passenger.so
                  PassengerRoot /usr/local/rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/passenger-4.0.23
                  PassengerDefaultRuby /usr/local/rbenv/versions/2.0.0-p247/bin/ruby

2. __Define VirtualHost Entry__

    - Edit /etc/httpd/conf.d/canoe.conf to add virtual host entry

        `sudo vim /etc/httpd/conf.d/canoe.conf`

            <VirtualHost *:80>
              ServerName shipit.staging.pardot.com
              DocumentRoot /var/canoe/current/public
              <Directory /var/canoe/current/public>
                # This relaxes Apache security settings.
                AllowOverride all
                # MultiViews must be turned off.
                Options -MultiViews
              </Directory>
            </VirtualHost>

3. __Kick Apache__

    `sudo service httpd restart`