# Team represents a GitHub team.
class GithubTeam
  def initialize(slug)
    @slug = slug
  end

  attr_reader :slug

  def url
    "#{Changeling.config.github_url}/orgs/#{organization}/teams/#{name}"
  end

  def html_link
    "<a href=\"#{html_escape(url)}\"><code>@#{html_escape(slug)}</code></a>"
  end

  def ==(other)
    other.is_a?(GithubTeam) && other.slug == slug
  end
  alias eql? ==

  def hash
    slug.hash
  end

  private

  def organization
    @slug.split("/").first
  end

  def name
    @slug.split("/").last
  end

  def html_escape(s)
    ERB::Util.html_escape(s)
  end
end
