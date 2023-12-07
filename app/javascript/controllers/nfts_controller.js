import { Controller } from "@hotwired/stimulus";
import Web3 from "web3";

// Connects to data-controller="nfts"
export default class extends Controller {
  static targets = ["loader", "image", "cards", "message"];

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

    this.messageTarget.style.visibility = "visible";
    this.messageTarget.style.display = "flex";

    this.cardsTarget.style.display = "none";
    this.loaderTarget.style.display = "flex";

    console.log("Connected NFT controller");

    try {

      this.web3 = await this.getWeb3Value();

      const contract = await new this.web3.eth.Contract(
        this.tokenURIABI,
        this.tokenContract
      );

      console.log(contract);
      const data = await this.getNFTMetadata(contract);
      console.log(data);

      await this.renderCards(data);

      this.messageTarget.style.visibility = "hidden";
      this.messageTarget.style.display = "none";
      this.loaderTarget.style.display = "none";
      this.cardsTarget.style.display = "flex";
    } catch (error) {
      console.log("Was unable to get contract: ", error);
    }
  }

  get cardsTarget() {
    return this.targets.find("cards");
  }

  async getWeb3Value() {
    let data;
    let web3;
    try {
      let res = await fetch("/endpoint");
      if (!res.ok) throw new Error("Could not get web3 value");

      data = await res.json();
      console.log(data.endpoint);
      web3 = new Web3(
        new Web3.providers.HttpProvider(
          data.endpoint
          // "https://polygon-mainnet.infura.io/v3/a981c2c6b5444a6b88acab192eae092d"
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


  async renderCards(data) {
    await data.forEach((item) => {
      const cardContainer = document.createElement("div");
      cardContainer.classList.add("d-flex", "align-items-stretch");

      const card = document.createElement("div");
      card.classList.add(
        "nft-card",
        "my-5",
        "mx-3",
        "p-3",
        "shadow",
        "rounded"
      );
      cardContainer.setAttribute(
        "data-url",
        `https://opensea.io/assets/matic/0x2562ffa357fbdd56024aea7d8e2111ad299766c9/${item.id}`
      );
      cardContainer.setAttribute("data-action", "click->nfts#openNFT");

      const image = document.createElement("img");
      image.src = item.image;
      image.alt = "NFT";

      const cardBody = document.createElement("div");
      cardBody.classList.add("card-body");

      const title = document.createElement("h5");
      title.classList.add("card-title", "mt-3");
      title.textContent = item.title;

      const description = document.createElement("p");
      description.classList.add("card-text", "mt-1");
      description.textContent = item.description;

      const owner = document.createElement("p");
      owner.classList.add("card-text", "mt-1");
      owner.textContent = `Current Owner: ${item.owner}`;

      const price = document.createElement("div");
      price.classList.add("d-flex", "flex-row");
      const icon = document.createElement("i");
      icon.classList.add("fa-brands", "fa-ethereum", "fa-xs", "mt-2", "mx-3");
      const small = document.createElement("small");
      small.textContent = `${item.price} MATIC`;

      price.appendChild(icon);
      price.appendChild(small);
      cardBody.appendChild(title);
      cardBody.appendChild(description);
      cardBody.appendChild(owner);
      cardBody.appendChild(price);
      card.appendChild(image);
      card.appendChild(cardBody);
      cardContainer.appendChild(card);
      this.cardsTarget.appendChild(cardContainer);
    });
  }

  openNFT(e) {
    console.log("Open NFT");
    const nft = e.currentTarget;
    const url = nft.getAttribute("data-url");
    console.log(url);
    window.open(url, "_blank");
  }

  async getMaticPrice(_price) {
    try {
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
      const maticPrice = data["matic-network"]["usd"];
      console.log("MATIC PRICE IS: ", maticPrice);
      return maticPrice;
    } catch (error) {
      console.log(error.message);
    }
  }

  async getNFTMetadata(contract) {
    let images = [];
    let objectArr = [];
    const reg = /\b(\w{6})\w+(\w{4})\b/g;

    try {
      let maticPrice = await this.getMaticPrice();

      for (let i = 1; i < 15; i++) {
        const tokenId = i;
        const result = await contract.methods.tokenURI(tokenId).call();
        const owner = await contract.methods.ownerOf(tokenId).call();

        console.log("OWNER >>> ", owner);

        if (!result) {
          console.log(`No result for tokenId ${tokenId}!`);
          continue;
        } else if (result === "metadata") {
          console.log(`Bad result for tokenId ${tokenId}!`);
          continue;
        }

        try {
          const response = await fetch(result, { timeout: 5000 });
          const fixedJsonString = await response.text();
          const parsedData = JSON.parse(
            fixedJsonString.replace(/,\s*([\]}])/g, "$1")
          ); // remove trailing comma
          // @dev Sample response: https://gateway.pinata.cloud/ipfs/QmV8ZcFPvEDxZDQowAGmqag1QCHg3SmevrpyDyUxGazEGA

          let pic = parsedData.image;
          let title = parsedData.name;
          let description = parsedData.description;
          let price = parsedData.attributes[4].value;
          let formattedPrice = price.replace("$", "");
          let formatOwner = owner.replace(reg, "$1****$2");

          let calculatedPrice = (formattedPrice * maticPrice).toFixed(2);

          let obj = {
            id: tokenId,
            title: title,
            description: description,
            price: calculatedPrice,
            image: pic,
            owner: formatOwner,
          };

          if (images.includes(pic)) {
            console.log(`Duplicate image for tokenId ${tokenId}!`);
          } else {
            images.push(pic);
            objectArr.push(obj);
          }
        } catch (error) {
          console.log(
            `Error fetching or parsing data for tokenId ${tokenId}:`,
            error
          );
          continue;
        }
      }

      return objectArr;
    } catch (error) {
      console.log("Was unable to get NFT metadata: ", error);
    }
  }
}
