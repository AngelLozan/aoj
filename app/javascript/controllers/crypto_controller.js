import { Controller } from "@hotwired/stimulus";
import Web3 from "web3";
import { Web3ModalAuth } from "@web3modal/auth-html";

// Connects to data-controller="crypto"
export default class extends Controller {
  static targets = [
    "modal",
    "buttonClose",
    "overlay",
    "buttonOpen",
    "wc",
    "xdefi",
    "pay",
    "address",
    "form",
    "loader",
  ];
  static values = {
    price: Number,
    projectId: String,
  };

  web3Modal;
  // static targets = ["connect", "pay", "address", "form", "loader"];

  web3 = new Web3(
    "https://eth-sepolia.g.alchemy.com/v2/w8AWYp_cLcfuGKs0fz9oIZb1YJdKQGvC"
  );

  async connect() {
    this.loaderTarget.style.display = "none";
    console.log("Crypto controller connected");
    this.payTarget.disabled = true;
    this.web3Modal = await this.getWalletConnect();
    if (typeof window.ethereum !== "undefined") {
      console.log("Metamask Detected");
    } else {
      console.log("Metamask not found");
    }
  }

  openModal() {
    this.modalTarget.classList.remove("hidden");
    this.overlayTarget.classList.remove("hidden");
  }

  closeModal() {
    this.modalTarget.classList.add("hidden");
    this.overlayTarget.classList.add("hidden");
  }

  async walletConnect() {
    const reg = /\b(\w{6})\w+(\w{4})\b/g;
    try {
      const data = await this.web3Modal.signIn({
        statement: "Connect to Web3Modal",
      });
      console.info(data);
      this.addressTarget.innerText = await data.address.replace(
        reg,
        "$1****$2"
      );
      this.buttonOpenTarget.innerText = "Connected!";
      this.payTarget.disabled = false;
      this.closeModal();
    } catch (err) {
      console.log(err.message);
    }
  }

  async xdefiConnect() {
    const reg = /\b(\w{6})\w+(\w{4})\b/g;
    try {
      let memo = "AOJ";
      if (window.xfi) {
        window.xfi.bitcoin.request(
          { method: "request_accounts", params: [{ memo }] },
          (error, accounts) => {
            if (!error) {
              this.addressTarget.value = accounts;
              this.addressTarget.innerText = accounts.replace(
                reg,
                "$1****$2"
              );
              this.buttonOpenTarget.innerText = "Connected!";
              this.payTarget.disabled = false;
            }
            this.closeModal();
          }
        );
      } else {
        this.xdefiTarget.innerText = "Please install!";
      }
    } catch (error) {
      console.log(error.message);
    }
  }

  get csrfToken() {
    const csrfMetaTag = document.querySelector("meta[name='csrf-token']");
    return csrfMetaTag ? csrfMetaTag.content : "";
  }

  async calculatePrice() {
    const price = this.priceValue;
    try {
      let res = await fetch(
        `https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=eur`,
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
      console.log(data["ethereum"]["eur"]);
      const ethPrice = data["ethereum"]["eur"];
      const calculatedPrice = price / ethPrice;
      console.log(calculatedPrice);
      return calculatedPrice;
    } catch (error) {
      console.log(error.message);
    }
  }

  async calculateBtcPrice() {
    const price = this.priceValue;
    try {
      let res = await fetch(
        `https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=eur`,
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
      console.log(data["bitcoin"]["eur"]);
      const btcPrice = data["bitcoin"]["eur"];
      const calculatedPrice = price / btcPrice;
      console.log(calculatedPrice);
      return calculatedPrice;
    } catch (error) {
      console.log(error.message);
    }
  }

  async calculateBTCFee() {
    try {
      let res = await fetch(
        `https://api.blockcypher.com/v1/btc/main`,
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
      console.log(data["high_fee_per_kb"]);
      const btcFee = data["high_fee_per_kb"];
      return btcFee;
    } catch (error) {
      console.log(error.message);
    }
  }

  async getWallet() {
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

  async getBtcWallet() {
    try {
      let res = await fetch(`/btcwallet/`, {
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
    try {
      let submitPayment = await fetch(`/orders/`, {
        method: "POST",
        headers: {
          Accept: "text/plain",
        },
        body: new FormData(this.formTarget),
      });
      console.log(submitPayment);
      let response = await submitPayment.text();
      console.log("RESPONSE:", response);

      if (response === "submitted") {
        console.log("Successful payment");
        window.location.href = "/paintings";
        // alert("Payment successful! You will receive an email with the details of your order.");
      }
    } catch (error) {
      console.log(error.message);
    }
  }

  async #permissions() {
    const reg = /\b(\w{6})\w+(\w{4})\b/g;
    try {
      this.accounts = await ethereum.request({ method: "eth_requestAccounts" });
      this.buttonOpenTarget.innerText = "Connected!";
      this.closeModal();
      this.payTarget.disabled = false;
      this.addressTarget.innerText = ethereum.selectedAddress.replace(
        reg,
        "$1****$2"
      );
      console.log("Eth Accounts: ", this.accounts);
    } catch (error) {
      console.log(error.message);
    }
  }

  async #sendEth() {
    this.loaderTarget.style.display = "inline-block";
    const price = await this.calculatePrice();
    console.log("PRICE", price);
    const address = await this.getWallet();
    const convertPrice = this.web3.utils.toWei(price, "ether");
    console.log("CONVERTED PRICE in WEI", convertPrice);

    const limit = await this.web3.eth.estimateGas({
      from: this.accounts[0],
      to: address,
      // value: this.web3.utils.toHex(convertPrice),
      // @dev Test value
      value: this.web3.utils.toWei(0.0001, "ether"),
    });
    console.log("LIMIT", limit);

    // @dev Test values
    // const maxPriorityFeePerGas = this.web3.utils.toWei(3, "gwei");
    // console.log("MAX PRIORITY FEE PER GAS", maxPriorityFeePerGas);
    // const maxFeePerGas = this.web3.utils.toWei(3, "gwei");
    // console.log("MAX FEE PER GAS", maxFeePerGas);

    // const baseFee = await this.web3.eth.getGasPrice(); // Get the current base fee
    // // Calculate maxFeePerGas as the sum of maxPriorityFeePerGas and baseFee
    // const maxFeePerGas = (BigInt(maxPriorityFeePerGas) + BigInt(baseFee)).toString();

    try {
      const txHash = await ethereum.request({
        method: "eth_sendTransaction",
        params: [
          {
            from: this.accounts[0],
            to: address,
            // data: this.web3.utils.toHex("AOJ"),
            // value: this.web3.utils.numberToHex(convertPrice),
            // @dev Test value
            value: this.web3.utils.toWei(0.0001, "ether"),
            gas: this.web3.utils.numberToHex(limit),
            maxPriorityFeePerGas: this.web3.utils.toWei(3, "gwei"),
            maxFeePerGas: this.web3.utils.toWei(3, "gwei"),
          },
        ],
      });
      console.log(txHash);

      if (txHash) {
        this.payTarget.innerText = "Paid";
        await this.postPayment(); // Goes to create order
        this.loaderTarget.style.display = "none";
      }
    } catch (error) {
      console.log(error.message);
      this.loaderTarget.style.display = "none";
      alert("Transaction didn't go through 🤔. Please try again.");
    }
  }

  async #sendBTC() {
    const feeRate = await this.calculateBTCFee();
    const amount = await this.calculateBtcPrice();
    const recipient = await this.getBtcWallet();
    const from = await this.addressTarget.value;
    const memo = "AOJ";
    console.log("FEE RATE", feeRate);
    console.log("AMOUNT", amount);
    console.log("RECIPIENT", recipient);
    console.log("FROM", from);
    
    try {
      window.xfi.bitcoin.request(
        {
          method: "transfer",
          params: [
            {
              feeRate,
              from,
              recipient,
              amount,
              memo,
            },
          ],
        },
        (error, result) => {
          console.debug(error, result);
          this.lastResult = { error, result };
        }
      );
    } catch (error) {
      console.log(error.message);
      alert("Transaction didn't go through 🤔. Please try again.");
    }
  }

  connectWallet(e) {
    console.log("connectWallet");
    this.#permissions();
  }

  pay(e) {
    e.preventDefault();
    if (ethereum.selectedAddress) {
      this.#sendEth();
    } else {
      this.#sendBTC();
    }

  }

  async getWalletConnect() {
    const web3Modal = await new Web3ModalAuth({
      projectId: this.projectIdValue,
      metadata: {
        name: "Web3Modal",
        description: "Web3Modal",
        url: "web3modal.com",
        icons: [
          "https://time.com/img/icons/wallet-connect.png",
        ],
      },
    });
    return web3Modal;
  }
}
