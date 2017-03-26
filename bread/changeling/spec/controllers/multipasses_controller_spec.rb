require "rails_helper"

RSpec.describe MultipassesController, :type => :controller do
  describe "CRUD" do
    let(:multipass) { Fabricate(:multipass) }
    let(:user) { User.create(github_login: "ys") }
    before do
      session[:user_id] = user.id
    end

    describe "GET index" do
      it "assigns @multipasses" do
        get :index
        expect(assigns(:multipasses)).to eq([multipass])
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end
    end

    describe "GET multipass" do
      it "shows multipass information" do
        expect(get(:show, params: { id: multipass.id })).to render_template(:show)
      end
    end

    context "#update" do
      subject do
        patch :update, params: {
          id: multipass.id,
          title: "update-test-title",
          multipass: multipass.attributes
        }
      end
    end
  end
end
