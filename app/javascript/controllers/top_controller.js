// Define your Stimulus controller
import { Controller } from "@hotwired/stimulus"
import Web3 from "web3";
import metadata from "../../assets/metadata.json";

export default class extends Controller {
  static targets = ["topBtn"];

  web3;


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
    {
      inputs: [
        {
          internalType: "uint256",
          name: "tokenId",
          type: "uint256",
        },
      ],
      name: "ownerOf",
      outputs: [
        {
          name: "owner",
          type: "address",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
  ];


  tokenContract = "0x2562ffA357FbDd56024AeA7D8E2111ad299766c9";

  async connect() {
    let contract;

    try {

      this.web3 = await this.getWeb3Value();

      if (localStorage.getItem("contractInfo") === null) {
        console.log("Grabbing new contract");
        contract = await new this.web3.eth.Contract(
          this.tokenURIABI,
          this.tokenContract
        );
        const contractInfo = {
          address: contract.options.address,
          abi: contract.options.jsonInterface,
        };
        localStorage.setItem("contractInfo", JSON.stringify(contractInfo));
      } else {
        console.log("Grabbing cached contract");
        const info = localStorage.getItem("contractInfo");
        const storedContractInfo = JSON.parse(info);
        contract = new this.web3.eth.Contract(
          storedContractInfo.abi,
          storedContractInfo.address
        );
      }

      // console.log("CONTRACT: ", contract);
      const data = await this.getNFTMetadata(contract);
    } catch (error) {
      console.log("Something went wrong in contract methods: ", error);
    }

    window.addEventListener("scroll", this.scrollFunction.bind(this));
  }

  async getWeb3Value() {
    let data;
    let web3;
    try {
      let res = await fetch("/endpoint");
      if (!res.ok) throw new Error("Could not get web3 value");

      data = await res.json();
      web3 = new Web3(
        new Web3.providers.HttpProvider(
          data.endpoint
        )
      );

    } catch (error) {
      console.log("Something went wrong grabbing endpoint: ", error);
    }
    return web3;
  }

   get csrfToken() {
    const csrfMetaTag = document.querySelector("meta[name='csrf-token']");
    return csrfMetaTag ? csrfMetaTag.content : "";
  }

// @dev this is cached so it doesn't overwhelm api. Updated on nft page.
  async getMaticPrice(_price) {
    let cachedPrice = localStorage.getItem("maticPrice");
    try {
      if (cachedPrice === null) {
        let res = await fetch(
          `https://api.coingecko.com/api/v3/simple/price?ids=matic-network&vs_currencies=usd`,
          {
            method: "GET",
            headers: {
              "Content-Type": "application/json",
              Accept: "application/json",
              "X-CSRF-Token": this.csrfToken,
            },
          }
        );
        let data = await res.json();
        // if (res.status !== 200) {
        //   return cachedPrice;
        // }
        const maticPrice = data["matic-network"]["usd"];
        // console.log("MATIC PRICE IS: ", maticPrice);
        localStorage.setItem("maticPrice", maticPrice);
        return maticPrice;
      } else {
        return cachedPrice;
      }
    } catch (error) {
      console.log(error.message);
    }
  }

  async getNFTMetadata(contract) {
    let objectArr = [];

    const reg = /\b(\w{6})\w+(\w{4})\b/g;

    try {
      let maticPrice = await this.getMaticPrice();

      metadata.forEach(async (nft) => {
        const tokenId = nft.token_id;
        let owner = localStorage.getItem(`owner${tokenId}`);

        if (owner === null) {
          try {
            console.log("Fetching owner, which wasn't cached for token: ", tokenId);
            owner = await contract.methods.ownerOf(tokenId).call();
            localStorage.setItem(`owner${tokenId}`, owner);
          } catch (error) {
            console.log("Error fetching data: ", error);
          }
        }
        console.log("OWNER >>> ", owner);
      });
    } catch (error) {
      console.log("Was unable to get NFT metadata: ", error);
    }
  }

  disconnect() {
    // Remove the scroll event listener when the controller disconnects
    window.removeEventListener("scroll", this.scrollFunction.bind(this));
  }

  scrollFunction() {
    const button = this.topBtnTarget;
    if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
      button.style.display = "block";
    } else {
      button.style.display = "none";
    }
  }

  scrollToTop() {
    // When the button is clicked, scroll to the top of the document
    document.body.scrollTop = 0; // For Safari
    document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE, and Opera
  }
}
