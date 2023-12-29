# frozen_string_literal: true

require 'test_helper'

module MVM
  class TestRegistry < Minitest::Test

    def setup
    end

    def test_registry_get_pid
      r = MVM.registry.pid
      assert_equal r, 'bd670872-76ce-3263-b933-3aa337e212a4'
    end

    def test_registry_get_version
      r = MVM.registry.version
      assert_equal r, 1
    end

    def test_registry_get_asset_contract
      r = MVM.registry.contract_from_asset 'c94ac88f-4671-3976-b60a-09064f1811e8'
      assert_equal r, '0x034a771797a1c8694bc33e1aa89f51d1f828e5a4'
    end

    def test_registry_get_user_contract
      r = MVM.registry.contract_from_user 'eb15555b-fc93-3b2c-a899-5a87d29422ec'
      assert_equal r, '0x4d16716bfe976a9c5c31b7c84bc89757edf7b823'
    end

    def test_registry_get_asset_id
      r = MVM.registry.asset_from_contract '0x034a771797a1c8694bc33e1aa89f51d1f828e5a4'
      assert_equal r, 'c94ac88f-4671-3976-b60a-09064f1811e8'
    end

    def test_registry_get_user_id
      r = MVM.registry.user_from_contract '0x4d16716bfe976a9c5c31b7c84bc89757edf7b823'
      assert_equal r['members'], ['eb15555b-fc93-3b2c-a899-5a87d29422ec']
      assert_equal r['threshold'], 1
    end

    def test_registry_get_user_id_by_contract
      r = MVM.registry.user_from_contract '0x4d16716bfe976a9c5c31b7c84bc89757edf7b823'
      assert_equal r, 'eb15555b-fc93-3b2c-a899-5a87d29422ec'
    end
  end
end
