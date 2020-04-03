# frozen_string_literal: true

module MixinBot
  class NodeCLI < Thor
    desc 'listallnodes', 'List all mixin nodes'
    def listallnodes
      return unless ensure_mixin_command_exist

      o, e, _s = Open3.capture3('mixin -n 35.188.235.212:8239 listallnodes')
      log e unless e.empty?
      log o
    end

    private

    def ensure_mixin_command_exist
      return true if command?('mixin')

      log '`mixin` command is not valid!'
      log 'Please install mixin software and provide a executable `mixin` command'
    end

    def command?(name)
      `which #{name}`
      $CHILD_STATUS.success?
    end
  end
end
