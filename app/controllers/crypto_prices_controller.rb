# frozen_string_literal: true

require "net/http"

class CryptoPricesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :load_cart_prints

  ALLOWED_IDS = %w[matic-network tezos ethereum bitcoin polygon-ecosystem-token].freeze
  ALLOWED_VS = %w[usd eur].freeze

  def show
    coin_id = params[:id].to_s
    vs = params[:vs].to_s

    coin_id = "matic-network" if coin_id.empty?
    vs = "usd" if vs.empty?

    unless ALLOWED_IDS.include?(coin_id)
      return render json: { error: "unsupported_coin" }, status: :bad_request
    end

    unless ALLOWED_VS.include?(vs)
      return render json: { error: "unsupported_currency" }, status: :bad_request
    end

    price = Rails.cache.fetch("coingecko:#{coin_id}:#{vs}", expires_in: 1.minute) do
      url = URI("https://api.coingecko.com/api/v3/simple/price?ids=#{coin_id}&vs_currencies=#{vs}")
      req = Net::HTTP::Get.new(url)
      api_key = Rails.application.credentials.coingecko_api_key || ENV["COINGECKO_API_KEY"]
      if api_key.present?
        req["x-cg-demo-api-key"] = api_key
        req["x-cg-pro-api-key"] = api_key
      end
      res = Net::HTTP.start(url.host, url.port, use_ssl: true) { |http| http.request(req) }
      unless res.is_a?(Net::HTTPSuccess)
        Rails.logger.error("Coingecko error status=#{res.code} body=#{res.body}")
        raise "Coingecko error"
      end
      data = JSON.parse(res.body)
      data.dig(coin_id, vs)
    end

    if price.nil?
      render json: { error: "price_unavailable" }, status: :bad_gateway
    else
      render json: { id: coin_id, vs: vs, price: price }
    end
  rescue StandardError => e
    Rails.logger.error("Coingecko error: #{e.message}")
    render json: { error: "price_unavailable" }, status: :bad_gateway
  end
end
