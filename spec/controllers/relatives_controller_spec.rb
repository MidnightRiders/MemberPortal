require 'spec_helper'

RSpec.describe RelativesController, type: :controller do
  context 'signed out' do
    skip 'rejects #new'
    skip 'rejects #create'
    skip 'rejects #destroy'
    skip 'accepts #accept_invitation'
  end

  context 'with Individual membership' do
    skip 'rejects #new with "Your account type does not permit relatives."'
    skip 'rejects #create'
    skip 'rejects #destroy'
    skip 'rejects #accept_invitation'
  end

  context 'with Family membership' do
    skip 'accepts #new'
    skip 'accepts #create'
    skip 'accepts #destroy'
    skip 'rejects #accept_invitation'
  end
end
