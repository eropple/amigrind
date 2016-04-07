require 'spec_helper'

describe Amigrind::Blueprints::Provisioners::LocalShell do
  it 'should correctly form from an array of strings' do
    p = Amigrind::Blueprints::Provisioners::LocalShell.new
    p.name = 'test'
    p.weight = 500

    p.command = [ 'ls -a', 'whoami', 'ps' ]

    expect(p.inline).to eq([ 'ls -a', 'whoami', 'ps'])
  end

  it 'should correctly form from a single string' do
    p = Amigrind::Blueprints::Provisioners::LocalShell.new
    p.name = 'test'
    p.weight = 500

    p.command = "ls -a\nwhoami\nps"

    expect(p.inline).to eq([ 'ls -a', 'whoami', 'ps'])
  end

  it 'should correctly form a Racker hash' do
    p = Amigrind::Blueprints::Provisioners::LocalShell.new
    p.command = "whoami"

    h = p.to_racker_hash
    expect(h[:type]).to eq('shell-local')
    expect(h[:command].split("\n")).to eq(p.inline)
  end
end
