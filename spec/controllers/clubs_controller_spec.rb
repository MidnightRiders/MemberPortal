require 'spec_helper'

describe ClubsController do

  skip 'GET index' do
    it 'assigns all clubs as @clubs' do
      club = Club.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:clubs)).to eq([club])
    end
  end

  skip 'GET show' do
    it 'assigns the requested club as @club' do
      club = Club.create! valid_attributes
      get :show, {id: club.to_param}, valid_session
      expect(assigns(:club)).to eq(club)
    end
  end

  skip 'GET new' do
    it 'assigns a new club as @club' do
      get :new, {}, valid_session
      expect(assigns(:club)).to be_a_new(Club)
    end
  end

  skip 'GET edit' do
    it 'assigns the requested club as @club' do
      club = Club.create! valid_attributes
      get :edit, {id: club.to_param}, valid_session
      expect(assigns(:club)).to eq(club)
    end
  end

  skip 'POST create' do
    skip 'with valid params' do
      it 'creates a new Club' do
        expect {
          post :create, {club: valid_attributes}, valid_session
        }.to change(Club, :count).by(1)
      end

      it 'assigns a newly created club as @club' do
        post :create, {club: valid_attributes}, valid_session
        expect(assigns(:club)).to be_a(Club)
        expect(assigns(:club)).to be_persisted
      end

      it 'redirects to the created club' do
        post :create, {club: valid_attributes}, valid_session
        expect(response).to redirect_to(Club.last)
      end
    end

    skip 'with invalid params' do
      it 'assigns a newly created but unsaved club as @club' do
        # Trigger the behavior that occurs when invalid params are submitted
        Club.any_instance.stub(:save).and_return(false)
        post :create, {club: { name:  'invalid value' }}, valid_session
        expect(assigns(:club)).to be_a_new(Club)
      end

      it 're-renders the "new" template' do
        # Trigger the behavior that occurs when invalid params are submitted
        Club.any_instance.stub(:save).and_return(false)
        post :create, {club: { name:  'invalid value' }}, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  skip 'PUT update' do
    skip 'with valid params' do
      it 'updates the requested club' do
        club = Club.create! valid_attributes
        # Assuming there are no other clubs in the database, this
        # specifies that the Club created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect(Club.any_instance).to_receive(:update).with({ name:  'MyString' })
        put :update, {id: club.to_param, club: { name:  'MyString' }}, valid_session
      end

      it 'assigns the requested club as @club' do
        club = Club.create! valid_attributes
        put :update, {id: club.to_param, club: valid_attributes}, valid_session
        expect(assigns(:club)).to eq(club)
      end

      it 'redirects to the club' do
        club = Club.create! valid_attributes
        put :update, {id: club.to_param, club: valid_attributes}, valid_session
        expect(response).to redirect_to(club)
      end
    end

    skip 'with invalid params' do
      it 'assigns the club as @club' do
        club = Club.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Club.any_instance.stub(:save).and_return(false)
        put :update, {id: club.to_param, club: { name:  'invalid value' }}, valid_session
        expect(assigns(:club)).to eq(club)
      end

      it 're-renders the "edit" template' do
        club = Club.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Club.any_instance.stub(:save).and_return(false)
        put :update, {id: club.to_param, club: { name:  'invalid value' }}, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  skip 'DELETE destroy' do
    it 'destroys the requested club' do
      club = Club.create! valid_attributes
      expect {
        delete :destroy, {id: club.to_param}, valid_session
      }.to change(Club, :count).by(-1)
    end

    it 'redirects to the clubs list' do
      club = Club.create! valid_attributes
      delete :destroy, {id: club.to_param}, valid_session
      expect(response).to redirect_to(clubs_url)
    end
  end

end
