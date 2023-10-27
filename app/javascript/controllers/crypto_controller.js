import { Controller } from "@hotwired/stimulus";
import Web3 from "web3";

// Connects to data-controller="crypto"
export default class extends Controller {

  static values = {
    price: Number,
  };

  static targets = ["connect", "pay", "address", "form"];

  web3 = new Web3('https://eth-sepolia.g.alchemy.com/v2/w8AWYp_cLcfuGKs0fz9oIZb1YJdKQGvC');

  connect() {
    console.log("Crypto controller connected");
    document.getElementsByClassName("stripe-button-el")[0].style.display = 'none';
    this.payTarget.disabled = true;
    if (typeof window.ethereum !== "undefined") {
      console.log("Metamask Detected");
    } else {
      console.log("Metamask not found");
    }
  }

  get csrfToken() {
    const csrfMetaTag = document.querySelector("meta[name='csrf-token']");
    return csrfMetaTag ? csrfMetaTag.content : "";
  }

  async calculatePrice() {
    const price = this.priceValue;
    try {
      let res = await fetch(`https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=eur`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": this.csrfToken,
        },
      });
      let data = await res.json();
      console.log(data["ethereum"]["eur"]);
      const ethPrice = data["ethereum"]["eur"];
      const calculatedPrice = price / ethPrice;
      console.log(calculatedPrice);
      return calculatedPrice;

    } catch (error) {
      console.log(error.message);
    }
  }

  async getWallet() {
    // e.preventDefault();
    // const id = e.currentTarget.getAttribute("data-id");

    try {
      let res = await fetch(`/wallet/`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": this.csrfToken,
        },
      });
      let data = await res.json();
      console.log(data); // address: address
      return data.address;
    } catch (error) {
      console.log(error.message);
    }
  }

  async postPayment(e) {
    // e.preventDefault();
    // const id = e.currentTarget.getAttribute('data-id');
    // const url = e.currentTarget.getAttribute('data-url');
    try {
        // window.open(url, "_blank");
        let submitPayment = await fetch(`/orders/`, {
            method: 'POST',
            headers: { "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": this.csrfToken },
            // body: JSON.stringify({ 'name': , 'address': , 'phone':  }) // submitting the form data
            body: new FormData(this.formTarget)
        })
        console.log(submitPayment);
        let response = await submitPayment.json();
        console.log(response);
        if (response.pt_status === 'submitted') {
            console.log("Successful payment");
        }
    } catch (error) {
        console.log(error.message);
    }
}

  async #permissions() {
    const reg = /\b(\w{6})\w+(\w{4})\b/g;
    this.accounts = await ethereum.request({ method: "eth_requestAccounts" });
    this.connectTarget.innerText = "Connected";
    this.payTarget.disabled = false;
    this.addressTarget.innerText = ethereum.selectedAddress.replace(
      reg,
      "$1****$2"
    );
    console.log("Eth Accounts: ", this.accounts);
  }

  async #sendEth() {
    const price = await this.calculatePrice();
    console.log("PRICE", price);
    const address = await this.getWallet();
    const convertPrice = this.web3.utils.toWei(price, "ether");
    console.log("CONVERTED PRICE", convertPrice);
    const limit = await this.web3.eth.estimateGas({
      from: this.accounts[0],
      to: address,
      value: this.web3.utils.toWei(0.001, "ether"),
    });
    try {
      const txHash = await ethereum.request({
        method: "eth_sendTransaction",
        params: [
          {
            from: this.accounts[0],
            to: address,
            data: "Purchase from the Art of Jaleh",
            value: this.web3.utils.numberToHex(convertPrice),

            // value: this.web3.utils.toHex(
            //   this.web3.utils.toWei(0.000000000001, "ether")
            // ),
            gas: this.web3.utils.numberToHex(limit),
            maxPriorityFeePerGas: this.web3.utils.toHex(
              this.web3.utils.fromWei(2, "gwei")
            ),
          },
        ],
      });
      console.log(txHash);
      // Set load spinner here
      if (txHash) {
        this.payTarget.innerText = "Paid";
        await this.postPayment(); // Goes to create order
      }
    } catch (error) {
      console.log(error.message);
    }
  }

  connectWallet(e) {
    console.log("connectWallet");
    this.#permissions();
  }

  pay(e) {
    e.preventDefault();
    this.#sendEth();
  }
}
