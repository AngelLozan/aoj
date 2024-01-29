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
    "metamask",
    "note",
    "id",
  ];
  static values = {
    price: Number,
    // projectId: String,
  };

  web3Modal;

  web3;

  printify_id;

  async connect() {
    this.loaderTarget.style.display = "none";
    console.log("Crypto controller connected");
    this.payTarget.disabled = true;
    try {
      this.web3 = await this.getWeb3Value();
      this.web3Modal = await this.getWalletConnect();
      if (typeof window.ethereum !== "undefined") {
        console.log("Metamask Detected");
      } else {
        console.log("Metamask not found");
        this.metamaskTarget.innerText = "Please install!";
      }
    } catch (error) {
      console.log("Something went wrong in connecting: ", error);
    }
  }
  // @dev Returns price plus shipping
  async getTotalPrice() {
    console.log("Getting price total with shipping");
    try {
      let res = await fetch(`/total_price`, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": this.csrfToken,
        },
        body: new FormData(this.formTarget),
      });
      let response = await res.json();
      console.log("RESPONSE:", response);
      let amount = response.amount;
      this.printify_id = response.stripe_order_id;
      this.idTarget.value = this.printify_id; // @dev Set value of stripe_order_id to printify order ID if need cancel.
      return [amount, this.printify_id];
    } catch (error) {
      console.log(
        "Was not able to get price total with shipping: ",
        error.message
      );
      this.displayFlashMessage(
        "Something went wrong, please try again 🤔",
        "warning"
      );
    }
  }

  async getWeb3Value() {
    let data;
    let web3;
    try {
      let res = await fetch("/alchemy");
      if (!res.ok) throw new Error("Could not get web3 value");

      data = await res.json();
      // console.log("DATA ENDPOINT FOR WEB3: ", data.endpoint);
      web3 = new Web3(new Web3.providers.HttpProvider(data.endpoint));
    } catch (error) {
      console.log("Something went wrong grabbing endpoint web3: ", error);
    }
    return web3;
  }

  openModal() {
    this.overlayTarget.classList.remove("hidden");
    this.overlayTarget.classList.add("showModal");
    this.modalTarget.classList.remove("hidden");
    this.modalTarget.classList.add("showModal");
  }

  closeModal() {
    this.modalTarget.classList.remove("showModal");
    this.modalTarget.classList.add("hidden");
    this.overlayTarget.classList.remove("showModal");
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
    // const reg = /\b(\w{6})\w+(\w{4})\b/g;
    try {
      let memo = "AOJ";
      if (window.xfi) {
        await window.xfi.bitcoin.request(
          { method: "request_accounts", params: [{ memo }] },
          (error, accounts) => {
            if (!error) {
              this.addressTarget.value = accounts[0];
              this.addressTarget.innerText = accounts[0];
              // this.addressTarget.innerText = accounts.replace(
              //   reg,
              //   "$1****$2"
              // );
              this.buttonOpenTarget.innerText = "Connected!";
              console.log("BTC address: ", accounts);
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

  // @dev calls getTotalPrice
  async calculatePrice() {
    // const price = this.priceValue;
    const values = await this.getTotalPrice();
    const price = values[0];
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
      this.displayFlashMessage(
        "Something went wrong, please try again 🤔",
        "warning"
      );
      await this.handleCancelPrintify();
    }
  }
  // @dev Calls getTotalPrice
  async calculateBtcPrice() {
    // const price = this.priceValue;
    const values = await this.getTotalPrice();
    const price = values[0];
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
      const calculatedPrice = (price / btcPrice) * 100000000; // Satoshis
      console.log(calculatedPrice);
      return calculatedPrice;
    } catch (error) {
      console.log(error.message);
      this.displayFlashMessage(
        "Something went wrong, please try again 🤔",
        "warning"
      );
      await this.handleCancelPrintify();
    }
  }

  // @dev Testnet / Mainnet uncomment
  async calculateBTCFee() {
    try {
      let res = await fetch(
        // `https://api.blockcypher.com/v1/btc/main`, // @dev Mainnet. Another api: https://api.blockchain.info/mempool/fees
        `https://api.blockcypher.com/v1/btc/test3`, // @dev Testnet
        {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
          },
        }
      );
      let data = await res.json();
      console.log(data["high_fee_per_kb"]);
      const btcFee = data["high_fee_per_kb"];
      return btcFee;
    } catch (error) {
      console.log(error.message);
      this.displayFlashMessage(
        "Something went wrong, please try again 🤔",
        "warning"
      );
    }
  }

  // @dev Testnet / Mainnet uncomment
  async checkBTCBalance(_address) {
    try {
      let res = await fetch(
        // `https://api.blockcypher.com/v1/btc/main/addrs/${_address}`, // @dev Mainnet only
        `https://api.blockcypher.com/v1/btc/test3/addrs/${_address}`, // @dev testnet only
        {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
          },
        }
      );
      let data = await res.json();
      console.log(data["balance"]);
      const balance = data["balance"];
      return balance;
    } catch (error) {
      console.log(error.message);
      this.displayFlashMessage(
        "Something went wrong, please try again 🤔",
        "warning"
      );
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
  // @dev Posts the form data to create so that order in AOJ system.
  async postPayment(e) {
    try {
      let submitPayment = await fetch(`/orders/`, {
        method: "POST",
        headers: {
          Accept: "text/plain",
          "X-CSRF-Token": this.csrfToken,
        },
        body: new FormData(this.formTarget),
      });
      console.log(submitPayment);
      let response = await submitPayment.text();
      console.log("RESPONSE:", response);

      if (response === "submitted") {
        console.log("Successful payment");
        this.formTarget.reset();
        this.displayFlashMessage(
          "Thank you for order, your painting will arrive soon.",
          "info"
        );
        setTimeout(() => {
          window.location.href = "/paintings";
        }, 1000);
        // window.location.href = "/paintings";
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
      this.addressTarget.value = ethereum.selectedAddress;
      this.addressTarget.innerText = ethereum.selectedAddress.replace(
        reg,
        "$1****$2"
      );
      console.log("Eth Accounts: ", this.accounts);
    } catch (error) {
      console.log(error.message);
    }
  }
  // @dev Calls calculatePrice then postPayment if success of tx (test values present)
  async #sendEth() {
    this.loaderTarget.style.display = "inline-block";
    const price = await this.calculatePrice();
    console.log("PRICE", price);
    const address = await this.getWallet();
    const convertPrice = this.web3.utils.toWei(price, "ether");
    console.log("CONVERTED PRICE in WEI", convertPrice);

    try {
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
            maxPriorityFeePerGas: this.web3.utils.toWei(3, "gwei"), // 3 or 5 (tip to miner)
            maxFeePerGas: this.web3.utils.toWei(5, "gwei"), // Optional Default in web3.js. Errors on metamask. Must be equal or higher.
          },
        ],
      });
      console.log("TXHASH", txHash);

      const interval = setInterval(() => {
        console.log("Attempting to get transaction receipt...");
        this.displayFlashMessage(
          "Please leave the page open for a moment. I'm grabbing a transaction receipt 🔐",
          "info"
        );
        this.web3.eth
          .getTransactionReceipt(txHash)
          .then((rec) => {
            if (rec) {
              console.log(rec);
              let receipt = rec;
              clearInterval(interval);
              if (receipt.status) {
                this.noteTarget.value = `Please verify this transaction is confirmed in your wallet & amount is comprable: https://etherscan.io/tx/${txHash}`;
                this.payTarget.innerText = "Paid";
                return this.postPayment(); // Goes to create order
                // this.loaderTarget.style.display = "none";
              }
            }
          })
          .then(() => {
            console.log("Transaction confirmed, posting payment");
            this.loaderTarget.style.display = "none";
          });
      }, 1000);
    } catch (error) {
      console.log(error.message);
      this.loaderTarget.style.display = "none";
      this.displayFlashMessage(
        "Transaction didn't go through. Please try again. 🤔",
        "warning"
      );
      await this.handleCancelPrintify();
      // alert("Transaction didn't go through 🤔. Please try again.");
    }
  }
  // @dev Calls calculateBTCPrice then postPayment if success of tx (test values present)
  async #sendBTC() {
    this.loaderTarget.style.display = "inline-block";
    console.log("BTC PAYMENT");
    const bitcoinTxHashRegex = /^[0-9a-fA-F]{64}$/;
    try {
      const balance = await this.checkBTCBalance(this.addressTarget.value);
      // const amount = await this.calculateBtcPrice();
      const feeRate = await this.calculateBTCFee();
      console.log("FEE RATE", feeRate);
      const amount = 10000; // @dev test amount of Satoshis
      console.log("BALANCE", balance);
      if (amount + feeRate > balance) {
        this.loaderTarget.style.display = "none";
        this.displayFlashMessage(
          "Not enough funds in your wallet. Please try again. 🤔",
          "warning"
        );
        // alert("Not enough funds in your wallet. Please try again.");
        return;
      }

      const recipient = await this.getBtcWallet();
      const from = this.addressTarget.value;
      const memo = "AOJ";

      console.log("AMOUNT", amount);
      console.log("RECIPIENT", recipient);
      console.log("FROM", from);

      const result = await new Promise((resolve, reject) => {
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
            if (result) {
              resolve(result);
            } else {
              reject(error || new Error("Transaction failed"));
            }
          }
        );
      });

      console.log("RESULT", result);

      if (bitcoinTxHashRegex.test(result) === true) {
        this.noteTarget.value = `Please verify this transaction is confirmed in your wallet & amount is comprable: https://mempool.space/tx/${result}`;
        this.payTarget.innerText = "Paid";
        await this.postPayment();
        this.loaderTarget.style.display = "none";
      } else {
        console.log("ERROR", result.error);
        this.loaderTarget.style.display = "none";
        this.handleCancelPrintify();
        this.displayFlashMessage(
          "Transaction didn't go through. Please try again. 🤔",
          "warning"
        );
        // alert("Transaction didn't go through 🤔. Please try again.");
      }
    } catch (error) {
      console.log(error.message);
      this.loaderTarget.style.display = "none";
      this.handleCancelPrintify();
      this.displayFlashMessage(
        "Transaction didn't go through. Please try again. 🤔",
        "warning"
      );
      // alert("Transaction didn't go through 🤔. Please try again.");
    }
  }

  connectWallet(e) {
    console.log("connectWallet");
    this.#permissions();
  }
  // @dev Calls either sendETH or sendBTC
  pay(e) {
    e.preventDefault();
    // @dev Mainnet only
    // const btcRegex = /^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$/;
    const btcRegex =
      /\b((bc|tb)(0([ac-hj-np-z02-9]{39}|[ac-hj-np-z02-9]{59})|1[ac-hj-np-z02-9]{8,87})|([13]|[mn2])[a-km-zA-HJ-NP-Z1-9]{25,39})\b/g;
    const from = this.addressTarget.value;
    if (btcRegex.test(from) === true) {
      this.#sendBTC();
    } else {
      this.#sendEth();
    }
  }

  async getWalletConnect() {
    let data;
    let id;
    try {
      let res = await fetch("/alchemy");
      if (!res.ok) throw new Error("Could not get alchemy endpoint");

      data = await res.json();
      // console.log(" WALLET CONNECT PROJECT ID: ", data.projectID);
      id = data.projectID;
    } catch (error) {
      console.log(
        "Something went wrong grabbing endpoint wallet connect: ",
        error
      );
    }

    const web3Modal = await new Web3ModalAuth({
      projectId: id,
      metadata: {
        name: "Web3Modal",
        description: "Web3Modal",
        url: "web3modal.com",
        icons: ["https://time.com/img/icons/wallet-connect.png"],
      },
    });
    return web3Modal;
  }

  displayFlashMessage(message, type) {
    const flashElement = document.createElement("div");
    flashElement.className = `alert alert-${type} alert-dismissible fade show m-1`;
    flashElement.role = "alert";
    flashElement.setAttribute("data-controller", "flash");
    flashElement.textContent = message;

    const button = document.createElement("button");
    button.className = "btn-close";
    button.setAttribute("data-bs-dismiss", "alert");

    flashElement.appendChild(button);
    document.body.appendChild(flashElement);

    setTimeout(() => {
      flashElement.remove();
    }, 5000);
  }

  async handleCancelPrintify() {
    console.log("Cancelling print order used to get shipping price");
    const form = document.querySelector("#order-form");

    const timeoutDuration = 30000; // 30 seconds
    const startTime = Date.now();

    let success = false;

    while (!success && Date.now() - startTime < timeoutDuration) {
      try {
        let res = await fetch(`/cancel_print_order`, {
          method: "POST",
          headers: {
            Accept: "application/json",
            "X-CSRF-Token": this.csrfToken,
          },
          body: new FormData(form),
        });

        let response = await res.json();
        console.log("RESPONSE:", response);

        if (response.status === "success") {
          console.log("Successfully cancelled print order");
          success = true; // Break out of the loop if successful
        } else {
          // this.displayFlashMessage("Something went wrong, please refresh the page 🤔", 'warning');
          await new Promise((resolve) => setTimeout(resolve, 1000));
        }
      } catch (error) {
        console.log("Error cancelling shipping: ", error.message);
      }
    }
  }
}
