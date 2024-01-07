require 'mail'
require 'json'
require 'uri'
require 'net/http'

class NftsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :nfts, :endpoint ]
  before_action :load_cart
  before_action :load_orders

  # def get_web3
  #   web3 = Web3::Eth::Rpc.new host: 'polygon-mainnet.infura.io/v3/',
  #                         port: 443,
  #                         connect_options: {
  #                           open_timeout: 20,
  #                           read_timeout: 140,
  #                           use_ssl: true,
  #                           rpc_path: '/a981c2c6b5444a6b88acab192eae092d'
  #                         }
  #   tokenContract = "0x2562ffA357FbDd56024AeA7D8E2111ad299766c9"
  #   # api = Web3::Eth::Etherscan.new ENV['POLYGON_SCAN_API']
  #   # abi = api.contract_getabi address: tokenContract

  #   abi = JSON.parse(File.read('app/assets/abi.json'))
  #   myContract = web3.eth.contract(abi)
  #   contract = myContract.at(tokenContract)
  #   return contract
  # end



  # def get_metadata
  #   images = [];
  #   objectArr = [];
  #   reg = /\b(\w{6})\w+(\w{4})\b/g;
  #   contract = get_web3

  #   try {
  #     maticPrice = get_matic_price
  #     response = ''
  #     15.times do |i|
  #       if i == 1 || i == 2
  #         next
  #       end
  #       tokenId = i;
  #       result = contract.methods.tokenURI(tokenId).call();
  #       owner = contract.methods.ownerOf(tokenId).call();
  #       puts 'owner >>> ', owner;
  #       if !result
  #         puts `No result for tokenId ${tokenId}!`;
  #         next
  #       elsif result === "metadata"
  #         puts `Bad result for tokenId ${tokenId}!`;
  #         next
  #       end

  #       if i == 3
  #         url = URI(result);
  #         http = Net::HTTP.new(url.host, url.port)
  #         http.use_ssl = true;
  #         request = Net::HTTP::Get.new(url)
  #         request["Content-Type"] = "application/json"
  #         request["Accept"] = "application/json"
  #         response = http.request(request)

  #         data = JSON.parse(response.read_body)
  #         response = await fetch(result, { timeout: 10000 });
  #       else
  #         response = await fetch(result, { timeout: 5000 });
  #       end



  #     end

  #         const fixedJsonString = await response.text();
  #         const parsedData = JSON.parse(
  #           fixedJsonString.replace(/,\s*([\]}])/g, "$1")
  #         ); // remove trailing comma
  #         // @dev Sample response: https://gateway.pinata.cloud/ipfs/QmV8ZcFPvEDxZDQowAGmqag1QCHg3SmevrpyDyUxGazEGA

  #         let pic = parsedData.image;
  #         let title = parsedData.name;
  #         let description = parsedData.description;
  #         let price = parsedData.attributes[4].value;
  #         let formattedPrice = price.replace("$", "");
  #         let formatOwner = owner.replace(reg, "$1****$2");

  #         let calculatedPrice = (formattedPrice * maticPrice).toFixed(2);

  #         let obj = {
  #           id: tokenId,
  #           title: title,
  #           description: description,
  #           price: calculatedPrice,
  #           image: pic,
  #           owner: formatOwner,
  #         };

  #         if (images.includes(pic)) {
  #           console.log(`Duplicate image for tokenId ${tokenId}!`);
  #         } else {
  #           images.push(pic);
  #           objectArr.push(obj);
  #         }
  #       } catch (error) {
  #         console.log(
  #           `Error fetching or parsing data for tokenId ${tokenId}:`,
  #           error
  #         );
  #         continue;
  #       }
  #     }

  #     return objectArr;
  #   } catch (error) {
  #     console.log("Was unable to get NFT metadata: ", error);
  #   }
  # }
  # end
  #
  def nfts
  end

  def endpoint
    render json: { endpoint: ENV['POLYGON_API'] }, status: :ok
  end




  # def set_image_urls
  #   render json: { message: "Image URLs updated successfully" }
  # end

  private

  # def get_matic_price
  #   url = URI("https://api.coingecko.com/api/v3/simple/price?ids=matic-network&vs_currencies=usd");
  #   http = Net::HTTP.new(url.host, url.port)
  #   http.use_ssl = true;

  #   request = Net::HTTP::Get.new(url)
  #   request["Content-Type"] = "application/json"
  #   request["Accept"] = "application/json"
  #   request["Cache-Control"] = "private, max-age=3600, no-revalidate"
  #   response = http.request(request)

  #   data = JSON.parse(response.read_body)
  #   maticPrice = data["matic-network"]["usd"];
  #   puts 'maticPrice >>> ', maticPrice;
  #   return maticPrice;
  # end

  # def set_image_urls
  #   puts request.body
  #   data = JSON.parse(request.body.read)
  #   @image_urls = data["images"]
  # end

  def load_cart
    if session[:cart].nil?
      session[:cart] = []
      @cart = session[:cart]
    else
      @cart = Painting.find(session[:cart])
    end
  end


  def load_orders
    @orders = Order.all
  end


end
