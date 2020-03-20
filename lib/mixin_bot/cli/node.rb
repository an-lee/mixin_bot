# frozen_string_literal: true

module MixinBot
  class NodeCLI < Thor
    desc 'listallnodes', 'List all mixin nodes'
    def listallnodes
      return unless ensure_mixin_command_exist

      o, e, s = Open3.capture3('mixin -n 35.188.235.212:8239 listallnodes')
      puts e unless e.empty?
      puts o
    end

    private

    def ensure_mixin_command_exist
      return true if command?('mixin')

      puts '`mixin` command is not valid!'
      puts 'Please install mixin software and provide a executable `mixin` command'
    end

    def command?(name)
      `which #{name}`
      $CHILD_STATUS.success?
    end
  end
end
