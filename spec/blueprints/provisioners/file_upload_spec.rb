require 'spec_helper'

describe Amigrind::Blueprints::Provisioners::FileUpload do
  it 'should correctly form a Racker hash' do
    p = Amigrind::Blueprints::Provisioners::FileUpload.new

    p.source = './foo.txt'
    p.destination = '/tmp/foo.txt'
    p.direction = :download

    h = p.to_racker_hash
    expect(h[:type]).to eq('file')
    expect(h[:source]).to eq('./foo.txt')
    expect(h[:destination]).to eq('/tmp/foo.txt')
    expect(h[:direction]).to eq('download')
  end
end
