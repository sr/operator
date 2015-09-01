class RepoServer < ActiveRecord::Base
  belongs_to :repo
  belongs_to :server
end
