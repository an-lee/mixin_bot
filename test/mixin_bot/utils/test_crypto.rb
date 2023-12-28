# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestCrypto < Minitest::Test
    def setup
    end

    def test_generate_unique_uuid
      uuid1 = '67d46d1b-0a46-4821-bb05-71efb9f90335'
      uuid2 = '073153fb-a5a3-4724-8658-fc9073e5510c'
      uuid3 = '5c749a9f-c45c-4f5c-a80e-09f3b3473cf7'

      assert MixinBot.utils.generate_unique_uuid(uuid1, uuid2) == '42a76a3b-775f-3ee6-baeb-3f76224f8deb'
      assert MixinBot.utils.generate_unique_uuid(uuid2, uuid1) == '42a76a3b-775f-3ee6-baeb-3f76224f8deb'
      assert MixinBot.utils.unique_uuid(uuid1, uuid2, uuid3) == 'f681e720-4981-3497-add1-4d90eabd7dce'
    end

    def test_generate_trace_from_hash
      hash = '9694efdb97561af52104a112d9d836ea7972a2f97536fead2e5a9a1ffe0ba6ab'
      trace_id = '9fd4e5b8-7dba-3145-a2a6-914930a77cb7'

      assert MixinBot.utils.generate_trace_from_hash(hash) == trace_id
    end

    def test_generate_rsa_key
      res = MixinBot.utils.generate_rsa_key

      assert res.key?(:public_key)
    end

    def test_generate_ed25519_key
      res = MixinBot.utils.generate_ed25519_key

      assert res.key?(:public_key)
    end
  end
end
