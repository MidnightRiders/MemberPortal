require 'spec_helper'

describe RevGuessesController do

  let(:valid_attributes) {
    { user: FactoryGirl.create(:user),
      match: FactoryGirl.create(:match),
      home_goals: (Random.rand * 5).to_i,
      away_goals: (Random.rand * 5).to_i }
  }

  context 'signed out' do
    describe 'GET index' do
      it ''
    end
  end
  describe "GET index" do
    it "assigns all rev_guesses as @rev_guesses" do
      rev_guess = RevGuess.create! valid_attributes
      get :index, { match_id: rev_guess.match, }
      assigns(:rev_guesses).should eq([rev_guess])
    end
  end

  describe "GET show" do
    it "assigns the requested rev_guess as @rev_guess" do
      rev_guess = RevGuess.create! valid_attributes
      get :show, { match_id: rev_guess.match, :id => rev_guess.to_param}
      assigns(:rev_guess).should eq(rev_guess)
    end
  end

  describe "GET new" do
    it "assigns a new rev_guess as @rev_guess" do
      get :new, { match_id: rev_guess.match, }
      assigns(:rev_guess).should be_a_new(RevGuess)
    end
  end

  describe "GET edit" do
    it "assigns the requested rev_guess as @rev_guess" do
      rev_guess = RevGuess.create! valid_attributes
      get :edit, { match_id: rev_guess.match, :id => rev_guess.to_param}
      assigns(:rev_guess).should eq(rev_guess)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new RevGuess" do
        expect {
          post :create, {:rev_guess => valid_attributes}
        }.to change(RevGuess, :count).by(1)
      end

      it "assigns a newly created rev_guess as @rev_guess" do
        post :create, {:rev_guess => valid_attributes}
        assigns(:rev_guess).should be_a(RevGuess)
        assigns(:rev_guess).should be_persisted
      end

      it "redirects to the created rev_guess" do
        post :create, {:rev_guess => valid_attributes}
        response.should redirect_to(RevGuess.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved rev_guess as @rev_guess" do
        # Trigger the behavior that occurs when invalid params are submitted
        RevGuess.any_instance.stub(:save).and_return(false)
        post :create, {:rev_guess => { "match" => "invalid value" }}
        assigns(:rev_guess).should be_a_new(RevGuess)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        RevGuess.any_instance.stub(:save).and_return(false)
        post :create, {:rev_guess => { "match" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested rev_guess" do
        rev_guess = RevGuess.create! valid_attributes
        # Assuming there are no other rev_guesses in the database, this
        # specifies that the RevGuess created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        RevGuess.any_instance.should_receive(:update).with({ "match" => "" })
        put :update, { match_id: rev_guess.match, :id => rev_guess.to_param, :rev_guess => { "match" => "" }}
      end

      it "assigns the requested rev_guess as @rev_guess" do
        rev_guess = RevGuess.create! valid_attributes
        put :update, { match_id: rev_guess.match, :id => rev_guess.to_param, :rev_guess => valid_attributes}
        assigns(:rev_guess).should eq(rev_guess)
      end

      it "redirects to the rev_guess" do
        rev_guess = RevGuess.create! valid_attributes
        put :update, { match_id: rev_guess.match, :id => rev_guess.to_param, :rev_guess => valid_attributes}
        response.should redirect_to([rev_guess.match,rev_guess])
      end
    end

    describe "with invalid params" do
      it "assigns the rev_guess as @rev_guess" do
        rev_guess = RevGuess.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        RevGuess.any_instance.stub(:save).and_return(false)
        put :update, { match_id: rev_guess.match, :id => rev_guess.to_param, :rev_guess => { "match" => "invalid value" }}
        assigns(:rev_guess).should eq(rev_guess)
      end

      it "re-renders the 'edit' template" do
        rev_guess = RevGuess.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        RevGuess.any_instance.stub(:save).and_return(false)
        put :update, { match_id: rev_guess.match, :id => rev_guess.to_param, :rev_guess => { "match" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested rev_guess" do
      rev_guess = RevGuess.create! valid_attributes
      expect {
        delete :destroy, {:id => rev_guess.to_param}
      }.to change(RevGuess, :count).by(-1)
    end

    it "redirects to the rev_guesses list" do
      rev_guess = RevGuess.create! valid_attributes
      delete :destroy, {:id => rev_guess.to_param}
      response.should redirect_to(rev_guesses_url)
    end
  end

end
