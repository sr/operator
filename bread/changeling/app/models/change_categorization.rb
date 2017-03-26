class ChangeCategorization
  STANDARD = "standard".freeze
  MAJOR = "major".freeze
  EMERGENCY = "emergency".freeze

  LIKELIHOOD_LOW = "low".freeze
  LIKELIHOOD_MEDIUM = "medium".freeze
  LIKELIHOOD_HIGH = "high".freeze

  # Matches #major hashtag in a pull request comment body
  MAJOR_COMMENT_MATCHER = /(\A|\s)#major(\z|\s)/

  def self.change_types
    return @change_types if defined?(@change_types)
    @change_types = [STANDARD, MAJOR, EMERGENCY].freeze
  end
end
