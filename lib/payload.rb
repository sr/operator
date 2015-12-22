require 'fileutils'
require 'tmpdir'

class Payload
  attr_accessor :options

  def initialize(options)
    self.options = options
  end

  def id
    @options[:id]
  end

  def name
    @_name ||= \
    # Camelize
    begin
      string = id.to_s
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
      string.gsub!('/', '::')
      string
    end
  end

  def artifacts_path
    @_artifacts_path ||= Dir.tmpdir
  end

  def current_link
    @options.fetch(:current_link, File.expand_path("current", repo_path))
  end

  def path_choices
    @options.fetch(:path_choices, %w(A B).map {|letter| File.expand_path("releases/#{letter}", repo_path)})
  end

  def artifact_prefix
    @options[:artifact_prefix] || ""
  end

  def build_version_file
    "#{current_link}/build.version"
  end

  # --------------------------------------------------------------------------
  def safe_path(path)
    return nil if path.to_s.strip.empty?
    # make double-damn sure this ends with a / (stupid unix/rsync)
    path += '/' unless path.to_s.strip[-1] == '/'
    path
  end

  def repo_path
    @_repo_path ||= \
      begin
        path = @options[:repo_path]
        if path.to_s.strip.empty?
          nil
        else
          safe_path(File.expand_path(path))
        end
      end
  end

end
