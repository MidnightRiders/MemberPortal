require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe RevGuessesController do

  # This should return the minimal set of attributes required to create a valid
  # RevGuess. As you add validations to RevGuess, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "match" => "" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RevGuessesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all rev_guesses as @rev_guesses" do
      rev_guess = RevGuess.create! valid_attributes
      get :index, {}, valid_session
      assigns(:rev_guesses).should eq([rev_guess])
    end
  end

  describe "GET show" do
    it "assigns the requested rev_guess as @rev_guess" do
      rev_guess = RevGuess.create! valid_attributes
      get :show, {:id => rev_guess.to_param}, valid_session
      assigns(:rev_guess).should eq(rev_guess)
    end
  end

  describe "GET new" do
    it "assigns a new rev_guess as @rev_guess" do
      get :new, {}, valid_session
      assigns(:rev_guess).should be_a_new(RevGuess)
    end
  end

  describe "GET edit" do
    it "assigns the requested rev_guess as @rev_guess" do
      rev_guess = RevGuess.create! valid_attributes
      get :edit, {:id => rev_guess.to_param}, valid_session
      assigns(:rev_guess).should eq(rev_guess)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new RevGuess" do
        expect {
          post :create, {:rev_guess => valid_attributes}, valid_session
        }.to change(RevGuess, :count).by(1)
      end

      it "assigns a newly created rev_guess as @rev_guess" do
        post :create, {:rev_guess => valid_attributes}, valid_session
        assigns(:rev_guess).should be_a(RevGuess)
        assigns(:rev_guess).should be_persisted
      end

      it "redirects to the created rev_guess" do
        post :create, {:rev_guess => valid_attributes}, valid_session
        response.should redirect_to(RevGuess.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved rev_guess as @rev_guess" do
        # Trigger the behavior that occurs when invalid params are submitted
        RevGuess.any_instance.stub(:save).and_return(false)
        post :create, {:rev_guess => { "match" => "invalid value" }}, valid_session
        assigns(:rev_guess).should be_a_new(RevGuess)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        RevGuess.any_instance.stub(:save).and_return(false)
        post :create, {:rev_guess => { "match" => "invalid value" }}, valid_session
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
        put :update, {:id => rev_guess.to_param, :rev_guess => { "match" => "" }}, valid_session
      end

      it "assigns the requested rev_guess as @rev_guess" do
        rev_guess = RevGuess.create! valid_attributes
        put :update, {:id => rev_guess.to_param, :rev_guess => valid_attributes}, valid_session
        assigns(:rev_guess).should eq(rev_guess)
      end

      it "redirects to the rev_guess" do
        rev_guess = RevGuess.create! valid_attributes
        put :update, {:id => rev_guess.to_param, :rev_guess => valid_attributes}, valid_session
        response.should redirect_to(rev_guess)
      end
    end

    describe "with invalid params" do
      it "assigns the rev_guess as @rev_guess" do
        rev_guess = RevGuess.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        RevGuess.any_instance.stub(:save).and_return(false)
        put :update, {:id => rev_guess.to_param, :rev_guess => { "match" => "invalid value" }}, valid_session
        assigns(:rev_guess).should eq(rev_guess)
      end

      it "re-renders the 'edit' template" do
        rev_guess = RevGuess.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        RevGuess.any_instance.stub(:save).and_return(false)
        put :update, {:id => rev_guess.to_param, :rev_guess => { "match" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested rev_guess" do
      rev_guess = RevGuess.create! valid_attributes
      expect {
        delete :destroy, {:id => rev_guess.to_param}, valid_session
      }.to change(RevGuess, :count).by(-1)
    end

    it "redirects to the rev_guesses list" do
      rev_guess = RevGuess.create! valid_attributes
      delete :destroy, {:id => rev_guess.to_param}, valid_session
      response.should redirect_to(rev_guesses_url)
    end
  end

end
