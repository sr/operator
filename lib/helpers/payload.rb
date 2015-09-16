require 'fileutils'

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

  def key
    @_key ||= @options[:key]
  end

  def local_git_path
    @_local_git_path ||= File.expand_path("github", local_path)
  end

  def local_artifacts_path
    @_local_artifacts_path ||= \
      begin
        artifact_path = File.expand_path("artifacts", local_path)
        FileUtils.mkdir_p(artifact_path) unless Dir.exist?(artifact_path)
        artifact_path
      end
  end

  def local_build_path
    @_local_build_path ||= File.expand_path("build", local_path)
  end

  def remote_current_link
    @options[:remote_current_link]
  end

  def remote_path_choices
    @options[:remote_path_choices]
  end

  def remote_path
    # TODO: do we need to look for remote_current_link to be set???
    @_remote_path ||= safe_path(@options[:remote_path])
  end

  # TODO: remove this!
  def remote_html_path
    @_remote_html_path ||= safe_path(@options[:remote_html_path])
  end

  def artifact_prefix
    @options[:artifact_prefix] || ""
  end

  def s3_bucket
    @options[:s3_bucket] || "pi"
  end

  def build_version_file
    "#{remote_current_link}/build.version"
  end

  # --------------------------------------------------------------------------
  def safe_path(path)
    return nil if path.to_s.strip.empty?
    # make double-damn sure this ends with a / (stupid unix/rsync)
    path += '/' unless path.to_s.strip[-1] == '/'
    path
  end

  def local_path
    @_local_path ||= \
      begin
        path = @options[:local_path]
        if path.to_s.strip.empty?
          nil
        else
          safe_path(File.expand_path(path))
        end
      end
  end

end
