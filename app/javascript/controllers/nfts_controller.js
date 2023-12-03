import { Controller } from "@hotwired/stimulus";
import Web3 from "web3";

// Connects to data-controller="nfts"
export default class extends Controller {

  static targets = ["loader", "image", "cards"]

  // to do: Put the endpoint env var in the data controller logic. Add static targets to view
  // web3 = new Web3(
  //   new Web3.providers.HttpProvider(
  //     "https://polygon-mainnet.infura.io/v3/a981c2c6b5444a6b88acab192eae092d"
  //   )
  // );
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
  ];

  tokenContract = "0x2562ffA357FbDd56024AeA7D8E2111ad299766c9";

  async connect() {
    this.cardsTarget.style.display = "none";
    this.loaderTarget.style.display = "inline-block";
    console.log("Connected NFT controller");

    try {
      this.web3 = await this.getWeb3Value();
      const contract = await new this.web3.eth.Contract(this.tokenURIABI, this.tokenContract);
      console.log(contract);
      const images = await this.getNFTMetadata(contract);
      console.log(images);
      // this.element.dataset.arrayData = JSON.stringify(images);
      await this.renderCards(images);

      this.loaderTarget.style.display = "none";
      this.cardsTarget.style.display = "block";
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

  async renderCards(images) {
    // const dataArray = await JSON.parse(this.element.dataset.arrayData);

    // Clear the existing content
    this.cardsTarget.innerHTML = '';

    // Append cards to the element
    await images.forEach(item => {
      const cardContainer = document.createElement('div');
      cardContainer.classList.add('col-sm-6', 'd-flex', 'align-items-stretch');

      const card = document.createElement('div');
      card.classList.add('card', 'my-5', 'mx-3', 'p-3', 'shadow', 'rounded');

      const image = document.createElement('img');
      image.src = item;
      image.alt = 'NFT';

      const cardBody = document.createElement('div');
      cardBody.classList.add('card-body');

      const title = document.createElement('h5');
      title.classList.add('card-title');
      title.textContent = "Title";
      // title.textContent = item.title;

      const description = document.createElement('p');
      description.classList.add('card-text');
      description.textContent = "Description";
      // description.textContent = item.description;

      const price = document.createElement('div');
      price.classList.add('d-flex', 'flex-row');
      const small = document.createElement('small');
      // small.textContent = item.price;
      small.textContent = "item.price";

      price.appendChild(small);
      cardBody.appendChild(title);
      cardBody.appendChild(description);
      cardBody.appendChild(price);
      card.appendChild(image);
      card.appendChild(cardBody);
      cardContainer.appendChild(card);
      this.cardsTarget.appendChild(cardContainer);
    });
  }

  async getNFTMetadata(contract) {
    let images = [];
    try {
      // Need to iterate next line for 15 ID's (15 nfts)
      // const tokenId = 1 // A token we'd like to retrieve its metadata of
      for (let i = 1; i < 15; i++) {
        const tokenId = i;
        // const tokenId = 1;
        const result = await contract.methods.tokenURI(tokenId).call();

        console.log(result); // https://gateway.pinata.cloud/ipfs/Qme6vLeZuC7CaFUPBBb9KhV6YmkTS14oGrpP4fxv5NQDXc

      // @dev Hosted on Pinata:
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

        const response = await fetch(result);
        console.log(response); // Response object

        const fixedJsonString = await response.text();
        const parsedData = JSON.parse(fixedJsonString.replace(/,\s*([\]}])/g, '$1'));
        console.log(parsedData);
        let pic = parsedData.image;
        console.log(pic);

        images.push(pic);
      }
      return images; //@dev returns array of images
    } catch (error) {
      console.log("Was unable to get NFT metadata: ", error);
    }
  }

}
