import { Controller } from "@hotwired/stimulus"
import Web3 from "web3";

// Connects to data-controller="nfts"
export default class extends Controller {
  // static targets = ["nft", "nftImage", "nftName", "nftDescription"]
  static values = {
    endpoint: String,
  };
  // to do: Put the endpoint env var in the data controller logic. Add static targets to view
  web3 = new Web3(
    new Web3.providers.HttpProvider(
      this.endpointValue
      //"https://polygon-mainnet.infura.io/v3/a981c2c6b5444a6b88acab192eae092d"
    )
  );

  tokenURIABI = [
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "tokenId",
                "type": "uint256"
            }
        ],
        "name": "tokenURI",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];

tokenContract = "0x2562ffA357FbDd56024AeA7D8E2111ad299766c9";


  async connect() {
    console.log("Connected NFT controller");
    try {
      const contract = await new web3.eth.Contract(tokenURIABI, tokenContract);
    } catch (error) {
      console.log("Was unable to get contract: ", error);
    }
  }

  async getNFTMetadata() {
    try {
      // Need to iterate next line for 15 ID's (15 nfts) Ex. below.
      // const tokenId = 1 // A token we'd like to retrieve its metadata of

      const result = await contract.methods.tokenURI(tokenId).call()

      console.log(result); // ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/101

      const ipfsURL = addIPFSProxy(result);

      const request = new Request(ipfsURL);
      const response = await fetch(request);
      const metadata = await response.json();
      console.log(metadata); // Metadata in JSON

      // Example metadata:
      // {
      //   image: 'ipfs://QmNdvtT9EmrUc6haJyN7ZanHNrsjd23v1ydG6r8jTGEZvq',
      //   attributes: [
      //     { trait_type: 'Clothes', value: 'Navy Striped Tee' },
      //     { trait_type: 'Hat', value: "Fisherman's Hat" },
      //     { trait_type: 'Fur', value: 'Gray' },
      //     { trait_type: 'Background', value: 'Army Green' },
      //     { trait_type: 'Eyes', value: 'Eyepatch' },
      //     { trait_type: 'Mouth', value: 'Bored' }
      //   ]
      // }

      const image = addIPFSProxy(metadata.image);
      // Return the IPFS hash combined with our Infura endpoint, after which we can directly access this in our browser to view the NFT!
      return image;
    } catch (error) {
      console.log("Was unable to get NFT metadata: ", error);
    }

}


  async addIPFSProxy(ipfsHash) {
    try {
      // const URL = `https://<YOUR_SUBDOMAIN>.infura-ipfs.io/ipfs/`
      const URL = `https://${this.endpointValue}.infura-ipfs.io/ipfs/`
      const hash = ipfsHash.replace(/^ipfs?:\/\//, '')
      const ipfsURL = URL + hash

      console.log(ipfsURL) // https://<subdomain>.infura-ipfs.io/ipfs/<ipfsHash>
      return ipfsURL
    } catch (error) {
      console.log("Was unable to add IPFS proxy: ", error);
    }

}


}
