class PardotShardExternal < ActiveRecord::Base
  self.abstract_class = true

  after_initialize :ensure_shard_connection_on_associations

  # add a class variable to stash our current shard number in
  class << self
    attr_accessor :shard_number, :shard_proxy, :sharded_associations

    def establish_connection_on_shard(shard_number)
      if shard_number.nil?
        raise 'Internal::API - DB_CONNECTION: shard can not be nil'
      end

      @shard_number = shard_number

      connection_name = shard_connection_name(shard_number)

      if ENV.include?(connection_name)
        # logger.info("SHARD: Using #{connection_name}")
        establish_connection(ENV[connection_name])
      else
        shard_connection = create_shard_connection_url(shard_number)
        # logger.info("SHARD: Using #{shard_connection} *")
        establish_connection(shard_connection) if shard_connection
      end
    end

    def shard_known?
      !@shard_number.blank?
    end

    def reset_shard_info!
      @shard_number = nil
    end

    def shard_connection_name(shard_number)
      # shard database configurations must follow this convention
      # "#{Rails.env}_pardot_shard#{shard_number}"
      "DB_CONN_SHARD#{shard_number}"
    end

    def default_shard_connection_name
      shard_connection_name(1)
    end

    def create_shard_connection_url(shard_number)
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
      ENV[shard_connection_name(shard_number)] = shard_conn_url

      shard_conn_url
    end
  end # << self


  def ensure_shard_connection_on_associations
    # setup the shard connection on associations so magic can happen
    associations = self.class.sharded_associations || []
    associations = associations.is_a?(Array) ? associations : [associations]

    if self.class.shard_known?
      associations.each do |assoc|
        assoc.try(:establish_connection_on_shard, self.class.shard_number)
      end
    end
  end

private
  def after_initialize
    readonly!
  end

end