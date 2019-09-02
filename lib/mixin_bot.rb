# frozen_string_literal: true

require 'http'
require 'base64'
require 'faye/websocket'
require 'openssl'
require 'jwt'
require 'jose'
require_relative './mixin_bot/api'

module MixinBot
  class<< self
    attr_accessor :client_id, :client_secret, :session_id, :pin_token, :private_key, :scope
  end

  def self.api
    @api ||= MixinBot::API.new
  end

  def self.blaze
    access_token = MixinBot.api.access_token('GET', '/', '')
    authorization = format('Bearer %<access_token>s', access_token: access_token)
    @blaze ||= Faye::WebSocket::Client.new(
      'wss://blaze.mixin.one/',
      ["Mixin-Blaze-1"],
      :headers => { 'Authorization' => authorization },
      ping: 60
    )
  end
end
