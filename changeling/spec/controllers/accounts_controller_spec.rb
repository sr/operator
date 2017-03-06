require "rails_helper"

describe AccountsController, :type => :controller do
  let(:user) { User.create }

  before do
    session[:user_id] = user.id
  end

  describe "GET show" do
    it "renders the edit template" do
      get :show
      expect(response).to render_template("show")
    end
  end

  describe "PUT update" do
    it "updates team" do
      expect do
        put :update, params: { user: { team: "tools" } }
      end.to change { user.reload.team }.to("tools")
    end

    %w{github_uid github_login}.each do |field|
      it "does not update #{field}" do
        expect do
          put :update, params: { user: { field => "tools" } }
        end.to_not change { user.reload.send(field) }
      end
    end
  end
end
