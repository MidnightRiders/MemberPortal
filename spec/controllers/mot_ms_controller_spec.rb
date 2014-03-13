require 'spec_helper'

describe MotMsController do

  # This should return the minimal set of attributes required to create a valid
  # MotM. As you add validations to MotM, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "user_id" => "MyString" } }

  describe "GET index" do
    it "assigns all mot_ms as @mot_ms" do
      mot_m = MotM.create! valid_attributes
      get :index, {}
      assigns(:mot_ms).should eq([mot_m])
    end
  end

  describe "GET show" do
    it "assigns the requested mot_m as @mot_m" do
      mot_m = MotM.create! valid_attributes
      get :show, {:id => mot_m.to_param}
      assigns(:mot_m).should eq(mot_m)
    end
  end

  describe "GET new" do
    it "assigns a new mot_m as @mot_m" do
      get :new, {}
      assigns(:mot_m).should be_a_new(MotM)
    end
  end

  describe "GET edit" do
    it "assigns the requested mot_m as @mot_m" do
      mot_m = MotM.create! valid_attributes
      get :edit, {:id => mot_m.to_param}
      assigns(:mot_m).should eq(mot_m)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new MotM" do
        expect {
          post :create, {:mot_m => valid_attributes}
        }.to change(MotM, :count).by(1)
      end

      it "assigns a newly created mot_m as @mot_m" do
        post :create, {:mot_m => valid_attributes}
        assigns(:mot_m).should be_a(MotM)
        assigns(:mot_m).should be_persisted
      end

      it "redirects to the created mot_m" do
        post :create, {:mot_m => valid_attributes}
        response.should redirect_to(MotM.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved mot_m as @mot_m" do
        # Trigger the behavior that occurs when invalid params are submitted
        MotM.any_instance.stub(:save).and_return(false)
        post :create, {:mot_m => { "user_id" => "invalid value" }}
        assigns(:mot_m).should be_a_new(MotM)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        MotM.any_instance.stub(:save).and_return(false)
        post :create, {:mot_m => { "user_id" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested mot_m" do
        mot_m = MotM.create! valid_attributes
        # Assuming there are no other mot_ms in the database, this
        # specifies that the MotM created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        MotM.any_instance.should_receive(:update).with({ "user_id" => "MyString" })
        put :update, {:id => mot_m.to_param, :mot_m => { "user_id" => "MyString" }}
      end

      it "assigns the requested mot_m as @mot_m" do
        mot_m = MotM.create! valid_attributes
        put :update, {:id => mot_m.to_param, :mot_m => valid_attributes}
        assigns(:mot_m).should eq(mot_m)
      end

      it "redirects to the mot_m" do
        mot_m = MotM.create! valid_attributes
        put :update, {:id => mot_m.to_param, :mot_m => valid_attributes}
        response.should redirect_to(mot_m)
      end
    end

    describe "with invalid params" do
      it "assigns the mot_m as @mot_m" do
        mot_m = MotM.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        MotM.any_instance.stub(:save).and_return(false)
        put :update, {:id => mot_m.to_param, :mot_m => { "user_id" => "invalid value" }}
        assigns(:mot_m).should eq(mot_m)
      end

      it "re-renders the 'edit' template" do
        mot_m = MotM.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        MotM.any_instance.stub(:save).and_return(false)
        put :update, {:id => mot_m.to_param, :mot_m => { "user_id" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested mot_m" do
      mot_m = MotM.create! valid_attributes
      expect {
        delete :destroy, {:id => mot_m.to_param}
      }.to change(MotM, :count).by(-1)
    end

    it "redirects to the mot_ms list" do
      mot_m = MotM.create! valid_attributes
      delete :destroy, {:id => mot_m.to_param}
      response.should redirect_to(mot_ms_url)
    end
  end

end
