class ServerTag < ApplicationRecord
  has_many :server_taggings, dependent: :destroy
  has_many :servers, through: :server_taggings

  validates :name, presence: true, uniqueness: true
end
