module ApplicationHelper
  def active?(type, value, output = " active")
    if type == value
      output.html_safe
    else
      ""
    end
  end

  def current_view
    params[:view] || Query::SQL
  end

  def table_columns
    @query.connection.columns(@query.extract_table_name(@ast)).map(&:name)
  end

  def audit_log_url
    "https://logs-#{Rails.application.config.x.datacenter}.pardot.com/app/kibana#/discover/Explorer-Audit-Log"
  end
end
