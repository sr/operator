class ServerTagging < ActiveRecord::Base
  belongs_to :server
  belongs_to :server_tag
end
