# frozen_string_literal: true

require 'test_helper'

module MVM
  class TestNft < Minitest::Test
    def setup
    end

    def test_mvm_collection_from_contract
      r = MVM.nft.collection_from_contract '0xCe773d418eBCBbA0Dc6601806ED8B9741df83C81'
      assert_equal r, 'dbef5999-fcb1-4f58-b84f-6b7af9694280'
    end

    def test_mvm_contract_from_collection
      r = MVM.nft.contract_from_collection 'dbef5999-fcb1-4f58-b84f-6b7af9694280'
      assert_equal r, '0xCe773d418eBCBbA0Dc6601806ED8B9741df83C81'
    end

    def test_mvm_owner_of_token
      r = MVM.nft.owner_of 'dbef5999-fcb1-4f58-b84f-6b7af9694280', '840'
      assert_equal r, '0xF376516D190c8e5f455C299fD191e93Bf4624245'
    end

    def test_mvm_token_of_owner_by_index
      r = MVM.nft.token_of_owner_by_index '0xCe773d418eBCBbA0Dc6601806ED8B9741df83C81', '0xF376516D190c8e5f455C299fD191e93Bf4624245', 0
       assert_equal r, 1095
    end
  end
end
