module Api
  class AuthenticationController < Controller
    skip_before_action :require_api_authentication
    before_action :require_email_authentication

    cattr_accessor :max_tries, :sleep_interval

    def phone
      if !current_user.phone.paired?
        message = "Your Canoe account is not paired with your phone. Please  " \
          "go to https://canoe.dev.pardot.com/auth/phone to setup your phone"
        return render(json: build_response(error: true, message: message))
      end

      if !current_user.authenticate_phone(max_tries, sleep_interval)
        message = "Phone authentication failed for #{current_user.email.inspect}"
        return render \
          json: build_response(error: true, message: message)
      end

      render json: build_response(error: false, message: "")
    end

    private

    def build_response(params)
      Canoe::PhoneAuthenticationResponse.new(params.merge(user_email: current_user.email)).as_json
    end
  end
end
