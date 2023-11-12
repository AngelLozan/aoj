import { Controller } from "@hotwired/stimulus";
import Web3 from "web3";

// Connects to data-controller="nfts"
export default class extends Controller {

  static targets = ["loader", "image", "cards"]

  static values = {
    endpoint: String,
  };
  // to do: Put the endpoint env var in the data controller logic. Add static targets to view
  web3 = new Web3(
    new Web3.providers.HttpProvider(
      // this.endpointValue
      "https://polygon-mainnet.infura.io/v3/a981c2c6b5444a6b88acab192eae092d"
    )
  );

  endpoint = "polygon-mainnet.infura.io/v3/a981c2c6b5444a6b88acab192eae092d";

  tokenURIABI = [
    {
      inputs: [
        {
          internalType: "uint256",
          name: "tokenId",
          type: "uint256",
        },
      ],
      name: "tokenURI",
      outputs: [
        {
          internalType: "string",
          name: "",
          type: "string",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
  ];

  tokenContract = "0x2562ffA357FbDd56024AeA7D8E2111ad299766c9";

  async connect() {https://polygon-mainnet.infura.io/
    this.cardsTarget.style.display = "none";
    this.loaderTarget.style.display = "inline-block";
    console.log("Connected NFT controller");
    try {
      const contract = await new this.web3.eth.Contract(this.tokenURIABI, this.tokenContract);
      console.log(contract);
      const image = await this.getNFTMetadata(contract);
      this.imageTarget.src = image;

      this.loaderTarget.style.display = "none";
      this.cardsTarget.style.display = "block";
    } catch (error) {
      console.log("Was unable to get contract: ", error);
    }
  }

  // sendImages(images) {
  //   const form = new FormData();
  //   form.append("images", JSON.stringify(images));

  //   fetch("/nfts", {
  //     method: "POST",
  //     body: form,
  //     headers: {
  //       "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
  //       "Content-Type": "application/json",
  //     },
  //   });
  // }

  async submitImages(data) {
    try {
      const response = await fetch("/set_image_urls", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
        },
        body: JSON.stringify({ images: data }),
      });

      if (response.ok) {
        console.log("Successfully updated image URLs");
      } else {
        console.error("Failed to update image URLs");
      }
    } catch (error) {
      console.error("Error:", error);
    }
  }

  async getNFTMetadata(contract) {
    let images = [];
    try {
      // Need to iterate next line for 15 ID's (15 nfts)
      // const tokenId = 1 // A token we'd like to retrieve its metadata of
      // for (let i = 0; i < 15; i++) {
        // const tokenId = i;
        const tokenId = 1;
        const result = await contract.methods.tokenURI(tokenId).call();

        console.log(result); // https://gateway.pinata.cloud/ipfs/Qme6vLeZuC7CaFUPBBb9KhV6YmkTS14oGrpP4fxv5NQDXc

        // const ipfsURL = this.addIPFSProxy(result);

      // Hosted on Pinata:
      //   {
      //     "attributes" : [ {
      //       "canvas" : "Black",
      //       "size" : "25X35 inches",
      //       "paint" : "acrylic",
      //       "pairing" : "Ships with original",
      //       "original" : "$800.00", <-- Format trailing comma away below
      //     }],
      //     "description" : "This painting depicts a vibrant gathering of women coming together.",
      //     "image" : "https://gateway.pinata.cloud/ipfs/Qme6vLeZuC7CaFUPBBb9KhV6YmkTS14oGrpP4fxv5NQDXc",
      //     "name" : "Gathering of Women"
      // }


        // const request = new Request(ipfsURL);
        const response = await fetch(result);
        console.log(response); // Response object

        const fixedJsonString = await response.text();
        const parsedData = JSON.parse(fixedJsonString.replace(/,\s*([\]}])/g, '$1'));
        console.log(parsedData); // Metadata in JSON
        const pic = parsedData.image;
        // const metadata = await response.json();
        // console.log(metadata); // Metadata in JSON
        // const pic = metadata.image
        console.log(pic);

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

        // const image = this.addIPFSProxy(metadata.image);
        // Return the IPFS hash combined with our Infura endpoint, after which we can directly access this in our browser to view the NFT!
        images.push(pic);
      // }
      // return images; //@dev returns array of images
      return pic
    } catch (error) {
      console.log("Was unable to get NFT metadata: ", error);
    }
  }

  async addIPFSProxy(ipfsHash) {
    try {
      const URL = `https://${this.endpoint}.infura-ipfs.io/ipfs/`
      // const URL = `https://${this.endpointValue}.infura-ipfs.io/ipfs/`;
      const hash = ipfsHash.replace(/^https?:\/\//, "");
      const ipfsURL = URL + hash;

      console.log(ipfsURL); // https://<subdomain>.infura-ipfs.io/ipfs/<ipfsHash>
      return ipfsURL;
    } catch (error) {
      console.log("Was unable to add IPFS proxy: ", error);
    }
  }
}
