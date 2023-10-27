import { Controller } from "@hotwired/stimulus";
import Web3 from "web3";

// Connects to data-controller="crypto"
export default class extends Controller {

  static values = {
    price: Number
  };

  static targets = ["connect", "pay", "address"];

  web3 = new Web3('https://eth-sepolia.g.alchemy.com/v2/w8AWYp_cLcfuGKs0fz9oIZb1YJdKQGvC');

  connect() {
    console.log("Crypto controller connected");
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

  connectWallet(e) {
    console.log("connectWallet");
    this.#permissions();
  }

  pay(e) {
    e.preventDefault();
    this.#sendEth();
  }

  async getWallet(e) {
    e.preventDefault();
    const id = e.currentTarget.getAttribute("data-id");

    try {
      let res = await fetch(`/wallet/`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": this.csrfToken,
        },
      });
      let data = res.json();
      console.log(data); // address: address
      return data.address;
    } catch (error) {
      console.log(error.message);
    }
  }

  async postPayment(e) {
    e.preventDefault();
    const id = e.currentTarget.getAttribute('data-id');
    const url = e.currentTarget.getAttribute('data-url');
    try {
        window.open(url, "_blank");
        let setStatus = await fetch(`/orders/`, {
            method: 'POST',
            headers: { "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": this.csrfToken },
            body: JSON.stringify({ 'status': 1 }) // 1 = successful payment
        })
        console.log(setStatus);
        let response = await setStatus.json();
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
    this.addressTarget.innerText = ethereum.selectedAddress.replace(
      reg,
      "$1****$2"
    );
    console.log("Eth Accounts: ", this.accounts);
  }

  async #sendEth() {
    const price = this.priceValue;
    const address = await this.getWallet();
    const limit = await this.web3.eth.estimateGas({
      from: this.accounts[0],
      to: address,
      // to: "0x2f318C334780961FB129D2a6c30D0763d9a5C970",
      value: this.web3.utils.fromWei(0.001, "ether"),
    });
    try {
      const txHash = await ethereum.request({
        method: "eth_sendTransaction",
        params: [
          {
            from: this.accounts[0],
            to: address,
            // to: "0x2f318C334780961FB129D2a6c30D0763d9a5C970",
            value: this.web3.utils.numberToHex(
              // this.web3.utils.fromWei(0.000001, "ether")
              this.web3.utils.fromWei(price, "ether")
            ),
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
}
