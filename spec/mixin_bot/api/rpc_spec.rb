# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Rpc do
  it 'gettransaction' do
    res = MixinBot.api.get_transaction('25bea01c02af130579e44cd878ce0dcfe82d8acb42d5dbaaf96b08735d5f6626')
    expect(res).not_to be_nil
  end

  it 'get_utxo' do
    res = MixinBot.api.get_utxo('25bea01c02af130579e44cd878ce0dcfe82d8acb42d5dbaaf96b08735d5f6626')
    expect(res).not_to be_nil
  end

  it 'sendrawtransaction' do
    res = MixinBot.api.send_raw_transaction('777700021700941284a95f31b25ec8c546008f208f88eee4419ccdcdbe6e3195e60128ca0001d8d911945795539e8ac26721de6c6ab86be4e2ccc423b4d41f60728087cc20d0000000000000000000010000000405f5e1000003f899a7fb9f7913d71ab49b005afd3a46a0d9eaf2eae5771cadd3a7962875a428a76f042f00942220d82ad39757d4b46d812b5df942fb7dcb88cf1b357bd02b598cd6eccfe1a8d5af4416b470e47e999c84a2c6f4e59226a781f7e8677b66503b698c04d7a973e292c951132f8338aae47da934f7b9d0f8dec5ccddfadf2e9a780003fffe02000000264e464f000020a0955c3a0c85fa43e9601963a77a3c44fa13bb250800899d379cab8dff786b57ffffff01fb785885a09bf6b5afa8b4fa3fca044785ab325580c25490244aec038a9e2befdcc27c9c234c7bd797c87f4fcbddebc977520f7560ab7a627ce85e2a05720f0a00000101')
    expect(res).not_to be_nil
  end

  it 'get snapshot' do
    res = MixinBot.api.get_snapshot('25bea01c02af130579e44cd878ce0dcfe82d8acb42d5dbaaf96b08735d5f6626')
    expect(res).not_to be_nil
  end

  it 'list snapshots' do
    res = MixinBot.api.list_snapshots
    expect(res).not_to be_nil
  end

  it 'list mint works' do
    res = MixinBot.api.list_mint_works
    expect(res).not_to be_nil
  end

  it 'list mint distributions' do
    res = MixinBot.api.list_mint_distributions
    expect(res).not_to be_nil
  end
end