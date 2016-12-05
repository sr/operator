module Api
  class AuthenticationController < ProtoController
    def phone
      if !current_user.phone.paired?
        message = "Your Canoe account is not paired with your phone. Please  " \
          "go to https://canoe.dev.pardot.com/auth/phone to setup your phone"
        return render(json: build_response(error: true, message: message))
      end

      options = {
        action: proto_request.action,
        max_tries: Canoe.config.phone_authentication_max_tries,
        sleep_interval: Canoe.config.phone_authentication_sleep_interval
      }

      if !current_user.authenticate_phone(options)
        message = "Phone authentication failed for #{current_user.email.inspect}"
        return render \
          json: build_response(error: true, message: message)
      end

      render json: build_response(error: false, message: "")
    end

    private

    def proto_request
      @proto_request ||= Canoe::PhoneAuthenticationRequest.decode_json(request.body.read)
    end

    def build_response(params)
      Canoe::PhoneAuthenticationResponse.new(params.merge(user_email: current_user.email)).as_json
    end
  end
end
