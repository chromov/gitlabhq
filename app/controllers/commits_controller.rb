require "base64"

class CommitsController < ApplicationController
  before_filter :project
  layout "project"

  # Authorize
  before_filter :add_project_abilities
  before_filter :authorize_read_project!
  before_filter :require_non_empty_project

  def index
    load_refs # load @branch, @tag & @ref

    @repo = project.repo
    limit, offset = (params[:limit] || 20), (params[:offset] || 0) 

    if params[:path]
      @commits = @repo.log(@ref, params[:path], :max_count => limit, :skip => offset)
    else
      @commits = @repo.commits(@ref, limit, offset)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def show
    @commit = project.repo.commits(params[:id]).first
    @notes = project.notes.where(:noteable_id => @commit.id, :noteable_type => "Commit").order("created_at DESC").limit(20)
    @note = @project.notes.new(:noteable_id => @commit.id, :noteable_type => "Commit")

    respond_to do |format| 
      format.html
      format.js { respond_with_notes }
    end
  end
end
