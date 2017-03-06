class GithubUser
  def initialize(login)
    @login = login
  end

  attr_reader :login

  def url
    "#{Changeling.config.github_url}/#{@login}"
  end

  def html_link
    "<a href=\"#{html_escape(Changeling.config.github_url + "/" + login)}\"><code>@#{html_escape(login)}</code></a>"
  end

  def ==(other)
    other.is_a?(GithubUser) && other.login == login
  end
  alias eql? ==

  def hash
    login.hash
  end

  private

  def html_escape(s)
    ERB::Util.html_escape(s)
  end
end
