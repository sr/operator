module WebmockHelpers
  def default_json_headers
    { "Content-Type" => "application/json" }
  end

  def stub_json_request(method, url, response_body, status = 200)
    stub_request(method, url)
      .to_return(status: status, body: response_body, headers: default_json_headers)
  end

  def stub_heroku_sfdc_token_request
    stub_request(:post, "https://#{SFDC_DOMAIN}/services/oauth2/token")
      .to_return(body: { access_token: "123", instance_url: "https://#{SFDC_DOMAIN}" }.to_json)
  end

  def stub_heroku_sfdc_query(query, body)
    stub_request(:get, %r{https://#{SFDC_DOMAIN}/services/data/v26\.0/query\?q=.*#{query}.*})
      .to_return(body: body, headers: { "Content-Type" => "application/json" })
  end
end
