import { Controller } from "@hotwired/stimulus";
import Web3 from "web3";
import metadata from "../../assets/metadata.json";
import tezMetadata from "../../assets/tezMetadata.json";
// import tezosImg from "../../assets/images/tezos.svg";

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
    let contract;
    this.messageTarget.style.visibility = "visible";
    this.messageTarget.style.display = "flex";

    this.cardsTarget.style.display = "none";
    this.loaderTarget.style.display = "flex";

    console.log("Connected NFT controller");

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
      // console.log(data);

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
      if(item.id === 200929){
        cardContainer.setAttribute(
          "data-url",
          `https://objkt.com/tokens/hicetnunc/${item.id}`
        );
      } else {
        cardContainer.setAttribute(
          "data-url",
          `https://opensea.io/assets/matic/0x2562ffa357fbdd56024aea7d8e2111ad299766c9/${item.id}`
        );
      }
      cardContainer.setAttribute("data-action", "click->nfts#openNFT");

      const image = document.createElement("img");
      image.src = item.image;
      image.alt = "NFT";

    const cardBody = document.createElement("div");
      cardBody.classList.add("card-body");

    const titleDiv = document.createElement("div");
      titleDiv.classList.add("d-flex", "flex-row", "align-items-center", "mt-3");
      const title = document.createElement("h5");
      title.classList.add("card-title", "mt-3");
      title.textContent = item.title;

    const infoDiv = document.createElement("div");
      infoDiv.classList.add("d-flex", "flex-column", "align-items-center", "mt-3");
      const description = document.createElement("p");
      description.classList.add("card-text", "mt-1");
      description.textContent = item.description;

    const ownerDiv = document.createElement("div");
      ownerDiv.classList.add("d-flex", "flex-row", "align-items-center", "mt-3");
      const owner = document.createElement("small");
      owner.classList.add("card-text", "mt-1");
      owner.textContent = `Owned by: ${item.owner}`;

    const price = document.createElement("div");
      price.classList.add("d-flex", "flex-row", "mt-3", "align-items-center");
      // const icon = document.createElement("i");
      const icon = document.createElement("img");
      // icon.classList.add("fa-brands", "fa-ethereum", "fa-xs", "mt-2", "mx-3");
      icon.classList.add("avatar", "mx-3");
      const small = document.createElement("small");

      if(item.id === 200929){
        icon.src = 'https://tezos.com/favicon.ico';
        small.textContent = `${item.price} XTZ`;
      } else {
        icon.src = 'https://polygonscan.com/assets/poly/images/svg/logos/token-light.svg?v=23.12.1.0';
        small.textContent = `${item.price} MATIC`;
      }

      price.appendChild(icon);
      price.appendChild(small);
      ownerDiv.appendChild(owner);
      titleDiv.appendChild(title);
      infoDiv.appendChild(description);
      cardBody.appendChild(titleDiv);
      cardBody.appendChild(price);
      cardBody.appendChild(ownerDiv);
      cardBody.appendChild(infoDiv);
      // cardBody.appendChild(title);
      // cardBody.appendChild(description);
      // cardBody.appendChild(owner);
      // cardBody.appendChild(price);
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


  get csrfToken() {
    const csrfMetaTag = document.querySelector("meta[name='csrf-token']");
    return csrfMetaTag ? csrfMetaTag.content : "";
  }

  async getMaticPrice(_price) {
    let cachedPrice = localStorage.getItem("maticPrice");
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
      if (res.status !== 200) {
        return cachedPrice;
      }
      const maticPrice = data["matic-network"]["usd"];
      console.log("MATIC PRICE IS: ", maticPrice);
      localStorage.setItem("maticPrice", maticPrice);
      return maticPrice;
    } catch (error) {
      console.log(error.message);
    }
  }

  async getTezosPrice() {
    let cachedPrice = localStorage.getItem("tezosPrice");
    try {
      let res = await fetch(
        `https://api.coingecko.com/api/v3/simple/price?ids=tezos&vs_currencies=usd`,
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
      if (res.status !== 200) {
        return cachedPrice;
      }
      const tezosPrice = data["tezos"]["usd"];
      console.log("Tezos PRICE IS: ", tezosPrice);
      localStorage.setItem("tezosPrice", tezosPrice);
      return tezosPrice;
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
        let formatOwner = owner.replace(reg, "$1****$2");

        let price = nft.attributes[4].value;
        let formattedPrice = price.replace("$", "");
        let calculatedPrice = (formattedPrice * maticPrice).toFixed(2);


        try {
          let nftObj = {
            id: tokenId,
            title: nft.name,
            description: nft.description,
            price: calculatedPrice,
            image: nft.image,
            owner: formatOwner,
          }

          objectArr.push(nftObj);

        } catch (error) {
          console.log("Error fetching or parsing data for tokenId: ", error);
        }

      });
      const tezosObj = await this.setTezosMetadata();
      objectArr.push(tezosObj);
      console.log("OBJECT ARRAY: ", objectArr);
      return objectArr;
    } catch (error) {
      console.log("Was unable to get NFT metadata: ", error);
    }
  }

  async setTezosMetadata() {
    // let xtzPrice = await this.getTezosPrice();
    // console.log("TEZOS PRICE: ", xtzPrice);

    const data = tezMetadata[0];
    const reg = /\b(\w{6})\w+(\w{4})\b/g;
    let owner = data.attributes[0].value;
    let formatOwner = owner.replace(reg, "$1****$2");

    let price = data.attributes[5].value
    // let formattedPrice = price.replace("$", "");
    // let calculatedPrice = (formattedPrice * xtzPrice).toFixed(2);


    let nftObj = {
      id: data.token_id,
      title: data.name,
      description: data.description,
      // price: calculatedPrice,
      price: price,
      image: data.image,
      owner: formatOwner,
    }

    return nftObj;
  }
}
