module ApplicationHelper
  def active?(type, value, output = " active")
    if type == value
      output.html_safe
    else
      ""
    end
  end

  def current_view
    params[:view] || sql_view
  end

  def audit_log_url
    "https://logs-#{Rails.application.config.x.datacenter}.pardot.com/app/kibana#/discover/Explorer-Audit-Log?_g=(refreshInterval:(display:Off,pause:!f,value:0),time:(from:now-7d,mode:quick,to:now))&_a=(columns:!(_source),filters:!(),index:'logstash-*',interval:auto,query:(query_string:(analyze_wildcard:!t,query:'app:explorer%20AND%20_exists_:query')),sort:!('@timestamp',desc))"
  end
end
