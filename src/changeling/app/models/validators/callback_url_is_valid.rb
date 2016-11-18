# Multipass validator for callback urls, must be https
class CallbackUrlIsValid < ActiveModel::Validator
  def validate(multipass)
    return if multipass.callback_url.nil?
    return if multipass.callback_url =~ /^https:/ || multipass.callback_url.empty?
    multipass.errors.add(:callback_url, "must be an HTTPS url: #{multipass.callback_url.inspect}")
  end
end
