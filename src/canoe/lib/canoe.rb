# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: canoe.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "bread.CreateDeployRequest" do
    optional :user_email, :string, 1
    optional :project, :string, 2
    optional :target_name, :string, 3
    optional :artifact_url, :string, 4
    optional :lock, :bool, 5
  end
  add_message "bread.CreateDeployResponse" do
    optional :error, :bool, 1
    optional :message, :string, 2
    optional :deploy_id, :int64, 3
  end
  add_message "bread.CreateTerraformDeployRequest" do
    optional :user_email, :string, 1
    optional :branch, :string, 2
    optional :commit, :string, 3
    optional :project, :string, 4
    optional :terraform_version, :string, 5
  end
  add_message "bread.CompleteTerraformDeployRequest" do
    optional :user_email, :string, 1
    optional :deploy_id, :int64, 2
    optional :successful, :bool, 3
    optional :request_id, :string, 4
    optional :project, :string, 5
  end
  add_message "bread.UnlockTerraformProjectRequest" do
    optional :user_email, :string, 1
    optional :project, :string, 2
  end
  add_message "bread.TerraformDeployResponse" do
    optional :error, :bool, 1
    optional :message, :string, 2
    optional :deploy_id, :int64, 3
    optional :request_id, :string, 4
    optional :project, :string, 5
  end
  add_message "bread.PhoneAuthenticationRequest" do
    optional :user_email, :string, 1
    optional :action, :string, 2
  end
  add_message "bread.PhoneAuthenticationResponse" do
    optional :error, :bool, 1
    optional :message, :string, 2
    optional :user_email, :string, 3
  end
end

module Bread
  CreateDeployRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("bread.CreateDeployRequest").msgclass
  CreateDeployResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("bread.CreateDeployResponse").msgclass
  CreateTerraformDeployRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("bread.CreateTerraformDeployRequest").msgclass
  CompleteTerraformDeployRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("bread.CompleteTerraformDeployRequest").msgclass
  UnlockTerraformProjectRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("bread.UnlockTerraformProjectRequest").msgclass
  TerraformDeployResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("bread.TerraformDeployResponse").msgclass
  PhoneAuthenticationRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("bread.PhoneAuthenticationRequest").msgclass
  PhoneAuthenticationResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("bread.PhoneAuthenticationResponse").msgclass
end
