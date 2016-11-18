# The basic user class, created from GitHub auth
class User < ActiveRecord::Base
  audited :except => :encrypted_github_token

  def self.create_with_omniauth(auth)
    require_herokai! auth["credentials"]["token"]

    user = User.find_or_create_by(github_uid: auth["uid"])
    user.github_login = auth["extra"]["raw_info"]["login"]
    user.github_token = auth["credentials"]["token"]
    user.save
    user
  end

  def github_token
    Fernet.verifier(ENV["FERNET_SECRET"], encrypted_github_token).message
  end

  def github_token=(token)
    self[:encrypted_github_token] = Fernet.generate(ENV["FERNET_SECRET"], token)
  end

  def self.ghost
    result = new
    result.github_login = "changeling-production"
    result.github_token = ENV["GITHUB_COMMIT_STATUS_TOKEN"]
    result
  end

  def self.require_herokai!(token)
    client = Clients::GitHub.new(token)
    unless client.heroku_org_member?
      raise(Exceptions::NotHerokaiError, "Not a Heroku organization member")
    end
  end

  def self.for_github_login(login)
    @csv_data ||= import_from_csv
    mapping = @csv_data[login]
    mapping && mapping.email.present? ? mapping.email : login
  end

  def self.for_heroku_email(email)
    employee = Employee.by_heroku_email(email)
    return unless employee
    User.find_by(github_login: employee.github)
  end

  def self.import_from_csv
    Employee.employees_hash
  end
end
