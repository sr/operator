class TagsController < ApplicationController
  before_filter :require_project

  def index
    @tags = current_project.tags
  end

  def latest
    tag = current_project.latest_tag
    @latest_tag = current_project.tag(tag.name)
  end
end
