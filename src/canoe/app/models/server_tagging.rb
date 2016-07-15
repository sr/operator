class ServerTagging < ApplicationRecord
  belongs_to :server
  belongs_to :server_tag
end
