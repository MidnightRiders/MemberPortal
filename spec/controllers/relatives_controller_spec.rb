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

RSpec.describe RelativesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Relative. As you add validations to Relative, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip('Add a hash of attributes valid for your model')
  }

  let(:invalid_attributes) {
    skip('Add a hash of attributes invalid for your model')
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RelativesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  skip 'GET new' do
    it 'assigns a new relative as @relative' do
      get :new, {}, valid_session
      expect(assigns(:relative)).to be_a_new(Relative)
    end
  end

  skip 'GET edit' do
    it 'assigns the requested relative as @relative' do
      relative = Relative.create! valid_attributes
      get :edit, { id: relative.to_param }, valid_session
      expect(assigns(:relative)).to eq(relative)
    end
  end

  skip 'POST create' do
    skip 'with valid params' do
      it 'creates a new Relative' do
        expect {
          post :create, { relative: valid_attributes }, valid_session
        }.to change(Relative, :count).by(1)
      end

      it 'assigns a newly created relative as @relative' do
        post :create, { relative: valid_attributes }, valid_session
        expect(assigns(:relative)).to be_a(Relative)
        expect(assigns(:relative)).to be_persisted
      end

      it 'redirects to the created relative' do
        post :create, { relative: valid_attributes }, valid_session
        expect(response).to redirect_to(Relative.last)
      end
    end

    skip 'with invalid params' do
      it 'assigns a newly created but unsaved relative as @relative' do
        post :create, { relative: invalid_attributes }, valid_session
        expect(assigns(:relative)).to be_a_new(Relative)
      end

      it "re-renders the 'new' template" do
        post :create, { relative: invalid_attributes }, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  skip 'POST accept_invitation' do
  end

  skip 'DELETE destroy' do
    it 'destroys the requested relative' do
      relative = Relative.create! valid_attributes
      expect {
        delete :destroy, { id: relative.to_param }, valid_session
      }.to change(Relative, :count).by(-1)
    end

    it 'redirects to the relatives list' do
      relative = Relative.create! valid_attributes
      delete :destroy, { id: relative.to_param }, valid_session
      expect(response).to redirect_to(relatives_url)
    end
  end

end
