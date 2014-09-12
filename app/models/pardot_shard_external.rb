class PardotShardExternal < ActiveRecord::Base
  self.abstract_class = true

  # add a class variable to stash our current shard number in
  class << self

    def establish_connection_on_shard(shard_number, datacenter)
      if shard_number.nil?
        raise 'Internal::API - DB_CONNECTION: shard can not be nil'
      end
      if datacenter.nil?
        raise 'Internal::API - DB_CONNECTION: datacenter can not be nil'
      end

      connection_name = shard_connection_name(shard_number, datacenter)

      if ENV.include?(connection_name)
        # logger.info("SHARD: Using #{connection_name}")
        establish_connection(ENV[connection_name])
      else
        shard_connection = create_shard_connection_url(shard_number, datacenter)
        # logger.info("SHARD: Using #{shard_connection} *")
        establish_connection(shard_connection) if shard_connection
      end
    end

    def shard_connection_name(shard_number, datacenter)
      # shard database configurations must follow this convention
      "DB_#{datacenter[0].upcase}_SHARD#{shard_number}"
    end

    def default_shard_connection_name
      shard_connection_name(1, Dallas)
    end

    def create_shard_connection_url(shard_number, datacenter)
      # grab our default shard config and bend it to use this shard
      default_shard_url = ENV[default_shard_connection_name]
      shard_conn_url = nil

      db_url_regex = /^(.*?)\:\/\/(.*?)\:(.*?)\@(.*?)\:(.*?)\/(.*?)$/
      sqlite_db_url_regex = /^sqlite3\:\/\/(.*?)\.sqlite3$/

      if match = default_shard_url.match(db_url_regex)
        adapter, username, password, host, port, db = match.captures

        # change the host and database to point to relevant shard
        if Rails.env.production?
          # in production, just change host
          host = host.gsub(/\d*$/,'') + shard_number.to_s
        else
          # in development and test, change database
          db = db.gsub(/\d*$/,'') + shard_number.to_s
        end

        shard_conn_url = \
          "#{adapter}://#{username}:#{password}@#{host}:#{port}/#{db}"
      elsif match = default_shard_url.match(sqlite_db_url_regex)
        file = match.captures.first
        file = file.gsub(/\d*$/,'') + shard_number.to_s

        shard_conn_url = "sqlite3://#{file}.sqlite3"
      end

      # store for later...
      ENV[shard_connection_name(shard_number, datacenter)] = shard_conn_url

      shard_conn_url
    end
  end # << self

private
  def after_initialize
    readonly!
  end

end