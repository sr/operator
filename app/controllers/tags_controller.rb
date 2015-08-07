class TagsController < ApplicationController
  before_filter :require_repo

  def index
    @tags = current_repo.tags
  end

  def latest
    tag = current_repo.latest_tag
    @latest_tag = current_repo.tag(tag.name)

    render template: "repos/show"
  end
end
