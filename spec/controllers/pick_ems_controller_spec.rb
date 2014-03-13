require 'spec_helper'


describe PickEmsController do

  # This should return the minimal set of attributes required to create a valid
  # PickEm. As you add validations to PickEm, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "match" => "" } }

  describe "GET index" do
    it "assigns all pick_ems as @pick_ems" do
      pick_em = PickEm.create! valid_attributes
      get :index, {}
      assigns(:pick_ems).should eq([pick_em])
    end
  end

  describe "GET show" do
    it "assigns the requested pick_em as @pick_em" do
      pick_em = PickEm.create! valid_attributes
      get :show, {:id => pick_em.to_param}
      assigns(:pick_em).should eq(pick_em)
    end
  end

  describe "GET new" do
    it "assigns a new pick_em as @pick_em" do
      get :new, {}
      assigns(:pick_em).should be_a_new(PickEm)
    end
  end

  describe "GET edit" do
    it "assigns the requested pick_em as @pick_em" do
      pick_em = PickEm.create! valid_attributes
      get :edit, {:id => pick_em.to_param}
      assigns(:pick_em).should eq(pick_em)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new PickEm" do
        expect {
          post :create, {:pick_em => valid_attributes}
        }.to change(PickEm, :count).by(1)
      end

      it "assigns a newly created pick_em as @pick_em" do
        post :create, {:pick_em => valid_attributes}
        assigns(:pick_em).should be_a(PickEm)
        assigns(:pick_em).should be_persisted
      end

      it "redirects to the created pick_em" do
        post :create, {:pick_em => valid_attributes}
        response.should redirect_to(PickEm.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved pick_em as @pick_em" do
        # Trigger the behavior that occurs when invalid params are submitted
        PickEm.any_instance.stub(:save).and_return(false)
        post :create, {:pick_em => { "match" => "invalid value" }}
        assigns(:pick_em).should be_a_new(PickEm)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        PickEm.any_instance.stub(:save).and_return(false)
        post :create, {:pick_em => { "match" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested pick_em" do
        pick_em = PickEm.create! valid_attributes
        # Assuming there are no other pick_ems in the database, this
        # specifies that the PickEm created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        PickEm.any_instance.should_receive(:update).with({ "match" => "" })
        put :update, {:id => pick_em.to_param, :pick_em => { "match" => "" }}
      end

      it "assigns the requested pick_em as @pick_em" do
        pick_em = PickEm.create! valid_attributes
        put :update, {:id => pick_em.to_param, :pick_em => valid_attributes}
        assigns(:pick_em).should eq(pick_em)
      end

      it "redirects to the pick_em" do
        pick_em = PickEm.create! valid_attributes
        put :update, {:id => pick_em.to_param, :pick_em => valid_attributes}
        response.should redirect_to(pick_em)
      end
    end

    describe "with invalid params" do
      it "assigns the pick_em as @pick_em" do
        pick_em = PickEm.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        PickEm.any_instance.stub(:save).and_return(false)
        put :update, {:id => pick_em.to_param, :pick_em => { "match" => "invalid value" }}
        assigns(:pick_em).should eq(pick_em)
      end

      it "re-renders the 'edit' template" do
        pick_em = PickEm.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        PickEm.any_instance.stub(:save).and_return(false)
        put :update, {:id => pick_em.to_param, :pick_em => { "match" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested pick_em" do
      pick_em = PickEm.create! valid_attributes
      expect {
        delete :destroy, {:id => pick_em.to_param}
      }.to change(PickEm, :count).by(-1)
    end

    it "redirects to the pick_ems list" do
      pick_em = PickEm.create! valid_attributes
      delete :destroy, {:id => pick_em.to_param}
      response.should redirect_to(pick_ems_url)
    end
  end

end
