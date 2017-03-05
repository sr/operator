module Api
  class AuthenticationController < ProtoController
    def phone
      if !current_user.phone.paired?
        message = "Your Canoe account is not paired with the Salesforce Authenticator app. Please  " \
          "go to https://canoe.dev.pardot.com/auth/phone to get setup"
        return render(json: build_response(error: true, message: message))
      end

      options = {
        action: proto_request.action,
        max_tries: Canoe.config.phone_authentication_max_tries,
        sleep_interval: Canoe.config.phone_authentication_sleep_interval
      }

      if !current_user.authenticate_phone(options)
        message = "Salesforce Authenticator verification failed for #{current_user.email.inspect}"
        return render \
          json: build_response(error: true, message: message)
      end

      render json: build_response(error: false, message: "")
    end

    private

    def proto_request
      @proto_request ||= Bread::PhoneAuthenticationRequest.decode_json(request.body.read)
    end

    def build_response(params)
      Bread::PhoneAuthenticationResponse.new(params.merge(user_email: current_user.email)).as_json
    end
  end
end
