# Client to publish events to Shuriken
class Shuriken
  def publish(event_type, multipass)
    client.post("/webhooks/changeling") do |req|
      req.body = payload(event_type, multipass).to_json
    end
  end

  def payload(event_type, multipass) # rubocop:disable Metrics/AbcSize
    {
      type: event_type,
      multipass: {
        id: multipass.id,
        title: multipass.title,
        repo_name: multipass.repository_name,
        pr_number: multipass.pull_request_number,
        reference_url: multipass.reference_url,
        requester: multipass.requester,
        impact: multipass.impact,
        impact_probability: multipass.impact_probability,
        change_type: multipass.change_type,
        backout_plan: multipass.backout_plan,
        peer_reviewer: multipass.peer_reviewer,
        sre_approver: multipass.sre_approver,
        rejector: multipass.rejector,
        emergency_approver: multipass.emergency_approver,
        testing: multipass.testing,
        team: multipass.team,
        complete: multipass.complete,
        created_at: multipass.created_at.iso8601,
        updated_at: multipass.updated_at.iso8601
      }
    }
  end

  def shuriken_host
    ENV["SHURIKEN_API_HOST"] || "shuriken.heroku.tools"
  end

  def client
    @client ||= Faraday.new(url: "https://#{shuriken_host}") do |connection|
      connection.headers["Content-Type"] = "application/json"
      connection.basic_auth "changeling", ENV["SHURIKEN_TOKEN"]
      connection.use ZipkinTracer::FaradayHandler, shuriken_host
      connection.adapter Faraday.default_adapter
    end
  end
end
