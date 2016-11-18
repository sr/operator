require "rails_helper"

describe "Actions for actors", :type => :request do
  def post_with_referer(path)
    post(path, headers: { "HTTP_REFERER" => "http://example.com" })
  end

  def delete_with_referer(path)
    delete(path, headers: { "HTTP_REFERER" => "http://example.com" })
  end

  let!(:multipass) { Fabricate(:unreviewed_multipass, requester: "atmos") }

  describe "POST review" do
    before do
      auth_as_herokai("ys")
    end

    it "sets the peer reviewer" do
      post_with_referer "/multipasses/#{multipass.id}/review"
      expect(multipass.reload.peer_reviewer).to eql("ys")
    end

    it "returns an error if multipass has been reviewed" do
      multipass.update_attributes(peer_reviewer: "1337807")
      expect do
        post_with_referer "/multipasses/#{multipass.id}/review"
      end.to_not change { multipass.reload.peer_reviewer }
      expect(flash[:error]).to eql "Peer reviewer is already set"
    end
  end

  describe "POST reject" do
    before do
      auth_as_herokai("ys")
    end

    it "sets the rejector", :type => :webmock do
      post_with_referer "/multipasses/#{multipass.id}/reject"
      expect(multipass.reload.rejector).to eql("ys")
    end

    it "returns an error if multipass is rejected", :type => :webmock do
      multipass.update_attributes(rejector: "1337807")
      expect do
        post_with_referer "/multipasses/#{multipass.id}/reject"
      end.to_not change { multipass.reload.rejector }
      expect(flash[:error]).to eql "Rejector is already set"
    end
  end

  describe "DELETE reopen" do
    before do
      auth_as_herokai("ys")
    end

    it "unsets rejector", :type => :webmock do
      delete_with_referer "/multipasses/#{multipass.id}/reject"
      expect(multipass.reload.rejector).to be_nil
    end

    it "returns an error if is not rejected by current_user", :type => :webmock do
      multipass.update_attributes(rejector: "1337807")
      expect do
        delete_with_referer "/multipasses/#{multipass.id}/reject"
      end.to_not change { multipass.reload.rejector }
      expect(flash[:error]).to eql "Rejector can only be unset by 1337807"
    end

    it "returns an error if rejector is not set", :type => :webmock do
      expect do
        delete_with_referer "/multipasses/#{multipass.id}/reject"
      end.to_not change { multipass.reload.rejector }
      expect(flash[:error]).to eql "Rejector is not set"
    end
  end

  describe "POST emergency" do
    before do
      auth_as_herokai("ys")
    end

    it "sets the emergency approver", :type => :webmock do
      stub_chat(multipass)
      post_with_referer "/multipasses/#{multipass.id}/emergency"
      expect(multipass.reload.emergency_approver).to eql("ys")
    end

    it "returns an error if multipass is emergency approved", :type => :webmock do
      stub_chat(multipass)
      multipass.update_attributes(emergency_approver: "1337807")
      expect do
        post_with_referer "/multipasses/#{multipass.id}/emergency"
      end.to_not change { multipass.reload.emergency_approver }
      expect(flash[:error]).to eql "Emergency approver is already set"
    end
  end

  describe "DELETE emergency" do
    before do
      auth_as_herokai("ys")
    end

    it "unsets the emergency approver", :type => :webmock do
      multipass.update_attributes(emergency_approver: "ys")
      delete_with_referer "/multipasses/#{multipass.id}/emergency"
      expect(multipass.reload.emergency_approver).to be_nil
    end

    it "returns an error if emergency is not set by current_user", :type => :webmock do
      multipass.update_attributes(emergency_approver: "1337807")
      expect do
        delete_with_referer "/multipasses/#{multipass.id}/emergency"
      end.to_not change { multipass.reload.emergency_approver }
      expect(flash[:error]).to eql "Emergency approver can only be unset by 1337807"
    end

    it "returns an error if emergency is not set", :type => :webmock do
      expect do
        delete_with_referer "/multipasses/#{multipass.id}/emergency"
      end.to_not change { multipass.reload.emergency_approver }
      expect(flash[:error]).to eql "Emergency approver is not set"
    end
  end

  describe "POST sre_approve" do
    context "Auth as SRE" do
      before do
        auth_as_herokai("jmervine")
      end

      it "sets the sre_approver" do
        post_with_referer "/multipasses/#{multipass.id}/sre-approve"
        expect(multipass.reload.sre_approver).to eql("jmervine")
      end

      it "returns an error if multipass has been approved" do
        multipass.update_attributes(sre_approver: "cmeckhardt")
        expect do
          post_with_referer "/multipasses/#{multipass.id}/sre-approve"
        end.to_not change { multipass.reload.sre_approver }
        expect(flash[:error]).to eql "Sre approver is already set"
      end
    end

    context "Auth as not SRE" do
      it "returns an error if not from sre" do
        auth_as_herokai("ys")
        expect do
          post_with_referer "/multipasses/#{multipass.id}/sre-approve"
        end.to_not change { multipass.reload.sre_approver }
        expect(flash[:error]).to eql "Sre approver must be in the GitHub SRE Approvers team"
      end
    end
  end

  describe "POST sync" do
    let(:ref_url) { "https://github.com/heroku/changeling/pull/12" }
    let!(:multipass) do
      Fabricate(:unreviewed_multipass,
                requester: "atmos",
                testing: false,
                reference_url: ref_url)
    end

    before do
      auth_as_herokai("ys")
    end

    it "syncs commit statuses", :type => :webmock do
      status = {
        "state" => "success",
        "context" => "ci/circleci"
      }
      url = "https://api.github.com/repos/heroku/changeling/statuses/#{multipass.release_id}"
      headers = { "Content-Type" => "application/json" }
      request = stub_request(:get, url).to_return(headers: headers, body: [status].to_json)
      post_with_referer "/multipasses/#{multipass.id}/sync"
      expect(request).to have_been_requested
      expect(multipass.reload).to be_testing
    end
  end

  describe "DELETE sre-approve" do
    before do
      auth_as_herokai("jmervine")
    end

    it "unsets the sre approver", :type => :webmock do
      multipass.update_attributes(sre_approver: "jmervine")
      delete_with_referer "/multipasses/#{multipass.id}/sre-approve"
      expect(multipass.reload.sre_approver).to be_nil
    end

    it "returns an error if approval was not made by current_user", :type => :webmock do
      multipass.update_attributes(sre_approver: "cmeckhardt")
      expect do
        delete_with_referer "/multipasses/#{multipass.id}/sre-approve"
      end.to_not change { multipass.reload.sre_approver }
      expect(flash[:error]).to eql "Sre approver can only be unset by cmeckhardt"
    end

    it "returns an error if SRE approver is not set", :type => :webmock do
      expect do
        delete_with_referer "/multipasses/#{multipass.id}/sre-approve"
      end.to_not change { multipass.reload.sre_approver }
      expect(flash[:error]).to eql "Sre approver is not set"
    end
  end

  describe "DELETE peer reviewer" do
    before do
      auth_as_herokai("ys")
    end

    it "unsets the peer reviewer", :type => :webmock do
      multipass.update_attributes(peer_reviewer: "ys")
      delete_with_referer "/multipasses/#{multipass.id}/review"
      expect(multipass.reload.peer_reviewer).to be_nil
    end

    it "returns an error if review was not made by current_user", :type => :webmock do
      multipass.update_attributes(peer_reviewer: "1337807")
      expect do
        delete_with_referer "/multipasses/#{multipass.id}/review"
      end.to_not change { multipass.reload.peer_reviewer }
      expect(flash[:error]).to eql "Peer reviewer can only be unset by 1337807"
    end

    it "returns an error if Peer reviewer is not set", :type => :webmock do
      expect do
        delete_with_referer "/multipasses/#{multipass.id}/review"
      end.to_not change { multipass.reload.peer_reviewer }
      expect(flash[:error]).to eql "Peer reviewer is not set"
    end
  end
end
