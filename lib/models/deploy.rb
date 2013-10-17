class Deploy < ActiveRecord::Base
  # validations, uniqueness, etc
  # validate type = %w[tag branch commit]
  belongs_to :deploy_target
  belongs_to :auth_user

  def log_path
    @_log_path ||= \
      begin
        filename = "#{self.deploy_target.name}_#{self.repo_name}_#{self.id}.log"
        File.join(ENV["CANOE_DIR"], 'log', filename)
      end
  end

  def log_contents
    File.read(log_path)
  end

end