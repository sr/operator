# Controller that handles all multipass interaction in the UI
class MultipassesController < ApplicationController
  instrument_action :index, :show, :update

  def index
    @by_team = params[:by_team] || current_user.team
    @multipasses = Multipass
      .includes(:github_repository)
      .includes(ticket_reference: :ticket)
      .by_team(@by_team)
      .complete(complete)
      .order("created_at desc")
      .page(params[:page])
  end

  def show
    @multipass = Multipass.find(params[:id])
    pipeline = HTML::Pipeline.new [
      HTML::Pipeline::MarkdownFilter,
      HTML::Pipeline::EmojiFilter
    ], gfm: true, asset_root: "/images"
    @backout_plan = pipeline.call(@multipass.backout_plan)[:output].to_s
    @bypass_form = params[:show_form] == "1"
  end

  def update
    @multipass = Multipass.find(params[:id])

    @multipass.audit_comment = "Browser: Updated from form by #{current_github_login}."

    if @multipass.update_from_form(multipass_params)
      flash[:success] = "Saved"

      redirect_to multipass_url(@multipass)
    else
      flash[:error] = nice_errors(@multipass)
      render :show
    end
  end

  def emergency
    approval_method(multipass.emergency_approve(current_github_login),
      "Browser: Emergency override by #{current_github_login}.")
  end

  def unset_emergency
    approval_method(multipass.unset_emergency_approver(current_github_login),
      "Browser: Emergency reset by #{current_github_login}.")
  end

  def review
    approval_method(multipass.review(current_github_login),
      "Browser: Peer review by #{current_github_login}.")
  end

  def remove_review
    approval_method(multipass.remove_review(current_github_login),
      "Browser: Remove peer review by #{current_github_login}")
  end

  def sre_approve
    approval_method(multipass.sre_approve(current_github_login),
      "Browser: SRE approve by #{current_github_login}.")
  end

  def remove_sre_approval
    approval_method(multipass.remove_sre_approval(current_github_login),
      "Browser: Remove SRE approval by #{current_github_login}")
  end

  def reject
    approval_method(multipass.reject(current_github_login),
      "Browser: Rejected by #{current_github_login}.")
  end

  def reopen
    approval_method(multipass.reopen(current_github_login),
      "Browser: Reopen by #{current_github_login}.")
  end

  def sync
    multipass.synchronize(current_github_login)
    redirect_back fallback_location: multipass_path(multipass)
  end

  private

  def approval_method(action, audit_comment)
    multipass.audit_comment = audit_comment
    unless action
      flash[:error] = nice_errors(multipass)
    end
    redirect_back fallback_location: multipass_path(multipass)
  end

  def multipass
    @multipass ||= Multipass.find(params[:id])
  end

  def nice_errors(multipass)
    multipass.errors.full_messages.to_sentence
  end

  def multipass_params
    params.require(:multipass).permit(
      :impact,
      :impact_probability,
      :change_type,
      :emergency_approver,
      :testing,
      :backout_plan,
      :emergency_override
    )
  end

  def complete
    case params[:complete]
    when nil, ""
      nil
    when "true", "t", "1"
      true
    else
      false
    end
  end
end
