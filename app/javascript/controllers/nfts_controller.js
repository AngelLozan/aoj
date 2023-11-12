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

  async connect() {
    this.cardsTarget.style.display = "none";
    this.loaderTarget.style.display = "inline-block";
    console.log("Connected NFT controller");
    try {
      const contract = await new this.web3.eth.Contract(this.tokenURIABI, this.tokenContract);
      console.log(contract);
      const data = await this.getNFTMetadata(contract);
      console.log(data);
      // this.element.dataset.arrayData = JSON.stringify(images);
      await this.renderCards(data);

      this.loaderTarget.style.display = "none";
      this.cardsTarget.style.display = "flex";
    } catch (error) {
      console.log("Was unable to get contract: ", error);
    }
  }

  get cardsTarget() {
    return this.targets.find("cards");
  }

  async renderCards(data) {
    // const dataArray = await JSON.parse(this.element.dataset.arrayData);

    // Clear the existing content
    // this.cardsTarget.innerHTML = '';

    // Append cards to the element
    await data.forEach(item => {

      const cardContainer = document.createElement('div');
      cardContainer.classList.add('col-sm-6', 'd-flex', 'align-items-stretch');

      const card = document.createElement('div');
      card.classList.add('card', 'my-5', 'mx-3', 'p-3', 'shadow', 'rounded');

      const image = document.createElement('img');
      image.src = item.image;
      image.alt = 'NFT';

      const cardBody = document.createElement('div');
      cardBody.classList.add('card-body');

      const title = document.createElement('h5');
      title.classList.add('card-title');
      title.textContent = item.title;

      const description = document.createElement('p');
      description.classList.add('card-text');
      description.textContent = item.description;

      const price = document.createElement('div');
      price.classList.add('d-flex', 'flex-row');
      const small = document.createElement('small');
      small.textContent = item.price;

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
    let objectArr = [];

    try {
      for (let i = 1; i < 15; i++) {
        const tokenId = i;
        const result = await contract.methods.tokenURI(tokenId).call();

        if (!result) {
          console.log(`No result for tokenId ${tokenId}!`);
          continue;
        }

        try {
          const response = await fetch(result, { timeout: 5000 }); // Adjust timeout as needed
          const fixedJsonString = await response.text();
          const parsedData = JSON.parse(fixedJsonString.replace(/,\s*([\]}])/g, '$1'));
          let pic = parsedData.image;
          let title = parsedData.name;
          let description = parsedData.description;
          let price = parsedData.attributes[4].value;

          let obj = {
            title: title,
            description: description,
            price: price,
            image: pic
          };

          if (images.includes(pic)) {
            console.log(`Duplicate image for tokenId ${tokenId}!`);
          } else {
            images.push(pic);
            objectArr.push(obj);
          }
        } catch (error) {
          console.log(`Error fetching or parsing data for tokenId ${tokenId}:`, error);
          continue;
        }
      }

      return objectArr;
    } catch (error) {
      console.log("Was unable to get NFT metadata: ", error);
    }
  }


}
