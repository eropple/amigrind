require 'spec_helper'

describe Amigrind::Blueprints::Provisioners::RemoteShell do
  it 'should correctly form from an array of strings' do
    p = Amigrind::Blueprints::Provisioners::LocalShell.new
    p.name = 'test'
    p.weight = 500

    p.command = [ 'ls -a', 'whoami', 'ps' ]

    expect(p.inline).to eq([ 'ls -a', 'whoami', 'ps'])
  end

  it 'should correctly form from a single string' do
    p = Amigrind::Blueprints::Provisioners::RemoteShell.new
    p.name = 'test'
    p.weight = 500

    p.command = "ls -a\nwhoami\nps"

    expect(p.inline).to eq([ 'ls -a', 'whoami', 'ps'])
  end

  it 'should correctly form a Racker hash' do
    p = Amigrind::Blueprints::Provisioners::RemoteShell.new
    p.command = "whoami\nls\nls"

    p.binary = true
    p.env_vars = {
      A: 55,
      B: 'hello'
    }
    p.execute_command = 'waffle'
    p.inline_shebang = '#! /i/dont/know/where/i/am'
    p.start_retry_timeout = 5.minutes

    h = p.to_racker_hash
    expect(h[:type]).to eq('shell')
    expect(h[:binary]).to eq(true)
    expect(h[:environment_vars]).to include("A=55")
    expect(h[:environment_vars]).to include("B=hello")
    expect(h[:execute_command]).to eq('waffle')
    expect(h[:inline_shebang]).to eq('#! /i/dont/know/where/i/am')
    expect(h[:start_retry_timeout]).to eq('300s')

    expect(h[:inline]).to eq([ 'whoami', 'ls', 'ls' ])
  end
end
