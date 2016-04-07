module Amigrind
  module Blueprints
    module Provisioners
      class AnsibleLocal < Amigrind::Blueprints::Provisioner
        # ansible is terrible! but amigrind tries to make it less terrible!

        # required
        attribute :playbook_file, String

        # optional
        attribute :command, String
        attribute :extra_arguments, Array[String]
        attribute :inventory_groups, Array[String]
        attribute :inventory_file, String
        attribute :playbook_dir, String
        attribute :playbook_paths, Array[String]
        attribute :group_vars, String
        attribute :host_vars, String
        attribute :role_paths, Array[String]
        attribute :staging_directory, String

        def to_racker_hash
          {
            type: 'ansible-local',

            playbook_file: @playbook_file,

            command: @command,
            extra_arguments: @extra_arguments,
            inventory_groups: @inventory_groups.nil? ? nil : @inventory_groups.join(','),
            inventory_file: @inventory_file,
            playbook_dir: @playbook_dir,
            playbook_paths: @playbook_paths,
            group_vars: @group_vars,
            host_vars: @host_vars,
            role_paths: @role_paths,
            staging_directory: @staging_directory
          }.delete_if { |_, v| v.nil? }
        end
      end
    end
  end
end
