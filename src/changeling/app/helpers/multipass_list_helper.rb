# Bootstrap and regex helpers for the multipass list.
module MultipassListHelper
  include ActionView::Helpers::UrlHelper

  def change_type_label(change_type)
    classes = case change_type
              when "major"
                "label label-primary"
              when "minor"
                "label label-success"
              else
                "label label-default"
              end

    raw "<span class='#{classes}'>#{change_type}</span>"
  end

  def multipass_title(multipass)
    if Changeling.config.pardot?
      pull = RepositoryPullRequest.new(multipass)
      ticket = pull.referenced_ticket
      repo_link = link_to(pull.repository_name.to_s, pull.repository_url)

      if ticket
        ticket_link = link_to(ticket.external_id, ticket.url)
        return raw("#{repo_link}: #{ticket_link} #{ticket.summary}")
      else
        return raw("#{repo_link}: #{pull.title}")
      end
    end

    if multipass.repository_name && multipass.pull_request_number
      link = link_to "PR##{multipass.pull_request_number}", multipass.reference_url
      raw "#{multipass.repository_name.split('/').last} (#{link})"
    else
      raw link_to multipass.reference_url, multipass.reference_url
    end
  end

  def unique_actor_update_link(multipass, name, actor)
    state = multipass.send(actor) ? "check" : "unchecked"
    title = raw("<i class='glyphicon glyphicon glyphicon-#{state}'></i>&nbsp;#{name}")
    current_actor = multipass.send(actor)
    method = current_actor ? :delete : :post
    link_to title, url_for_actor(actor, multipass), method: method
  end

  def url_for_actor(actor, multipass)
    case actor
    when :peer_reviewer
      review_multipass_path(multipass)
    when :sre_approver
      sre_approve_multipass_path(multipass)
    when :emergency_approver
      emergency_multipass_path(multipass)
    when :rejector
      reject_multipass_path(multipass)
    end
  end
end
