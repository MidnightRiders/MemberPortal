require 'spec_helper'

describe Relative do
  it 'strips whitespace from an invited email before validation' do
    relative = Relative.new(info: { invited_email: ' test.email@with-spaces.com ', pending_approval: true })

    relative.valid?

    expect(relative.info[:invited_email]).to eq('test.email@with-spaces.com')
  end
end
