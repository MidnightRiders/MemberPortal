require 'spec_helper'

RSpec.describe RelativesController, type: :controller do
  context 'signed out' do
    pending 'rejects #new'
    pending 'rejects #create'
    pending 'rejects #destroy'
    pending 'accepts #accept_invitation'
  end

  context 'with Individual membership' do
    skip 'rejects #new with "Your account type does not permit relatives."'
    pending 'rejects #create'
    pending 'rejects #destroy'
    pending 'rejects #accept_invitation'
  end

  context 'with Family membership' do
    pending 'accepts #new'
    pending 'accepts #create'
    pending 'accepts #destroy'
    pending 'rejects #accept_invitation'
  end
end
