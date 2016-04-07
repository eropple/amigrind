require 'spec_helper'

describe Amigrind::Blueprints::Provisioners::AnsibleLocal do
  it 'should correctly form a Racker hash' do
    # only testing inventory_groups here as the rest are already covered by other tests.
    p = Amigrind::Blueprints::Provisioners::AnsibleLocal.new
    p.playbook_file =

    p.inventory_groups = [ 'bob', 'jim' ]


    h = p.to_racker_hash
    expect(h[:type]).to eq('ansible-local')
    expect(h[:inventory_groups]).to eq('bob,jim')
  end
end
