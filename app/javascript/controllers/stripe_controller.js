import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "inputs", "total", "id"]
  static values = {
    publishableKey: String,
  }

  formSubmitListener = null;
  clickCount = 0;
  submittedForm = false;

  async connect() {
    console.log("Connected stripe controller");
    this.setupFormListener();
    this.observeStripeModalCloseButton();
  }


    observeStripeModalCloseButton() {
      const targetNode = document.body;

      const observer = new MutationObserver((mutationsList, observer) => {
        for (const mutation of mutationsList) {
          for (const node of mutation.addedNodes) {
            if (node.tagName && node.tagName.toLowerCase() === 'iframe') {
              console.log("Stripe modal iframe added");
            }
          }

          for (const node of mutation.removedNodes) {
            if (node.tagName && node.tagName.toLowerCase() === 'iframe') {
              console.log("Stripe modal iframe removed");
              if (this.submittedForm === false) {
                this.handleStripeClosed();
                console.log("Stripe modal closed before submission, canceling order");
              }
            }
          }
        }
      });

      const config = { childList: true, subtree: true };

      observer.observe(targetNode, config);
      console.log("Mutation observer connected");
    }

  async setupFormListener() {
    console.log("Setting up form listener");

    this.formSubmitListener = async (event) => {
      event.preventDefault();
      try {
        const [amount, stripeOrderId] = await this.amount();
        await this.initializeStripe(amount, stripeOrderId);
        await this.loadStripeScript();
      } catch (error) {
        console.log("Error in form listener: ", error.message);
        await this.handleStripeClosed();
      }
    };

    this.formTarget.addEventListener("submit", this.formSubmitListener);
  }

  async handleStripeClosed() {
    // Handle the closure of the Stripe Checkout modal
    console.log("Stripe Checkout modal closed");

    try {
      let res = await fetch(`/cancel_print_order`, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": this.csrfToken,
        },
        body: new FormData(this.formTarget),
      });
      let response = await res.json();
      console.log("RESPONSE:", response);
      if (response.status === "success") {
        console.log("Successfully cancelled print order");
      }
    } catch (error) {
      console.log("Was not able to get price total with shipping: ", error.message);
    }

  }

  async loadStripeScript() {
    return new Promise((resolve) => {
      const stripeScript = document.createElement("script");
      stripeScript.src = "https://checkout.stripe.com/checkout.js";
      stripeScript.onload = () => resolve();
      document.body.appendChild(stripeScript);
    }).then(() => {
      // Once the Stripe script is loaded, execute the script and trigger the form submission
      this.executeStripeScript();
    });
  }

  executeStripeScript() {
    const stripeButton = document.querySelector(".stripe-button-el");

    if (stripeButton) {
      stripeButton.click();
      this.submittedForm = true;
      this.clickCount++;
    } else {
      console.log("Stripe button not found");
    }
  }


 async initializeStripe(_amount, _stripe_order_id) {
    const stripeButtonScript = document.createElement("script");
    stripeButtonScript.src = "https://checkout.stripe.com/checkout.js";
    stripeButtonScript.classList.add("stripe-button");
    stripeButtonScript.dataset.key = this.publishableKeyValue;
    stripeButtonScript.dataset.description = `Your art is on the way!`;
    stripeButtonScript.dataset.amount = _amount;
    stripeButtonScript.dataset.locale = "auto";

    this.inputsTarget.appendChild(stripeButtonScript);

    this.idTarget.value = _stripe_order_id;
    this.totalTarget.value = _amount;
  }

  async amount() {
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
      let stripe_order_id = response.stripe_order_id;
      return [amount, stripe_order_id];
    } catch (error) {
      console.log("Was not able to get price total with shipping: ", error.message);
    }
  }

  get csrfToken() {
    const csrfMetaTag = document.querySelector("meta[name='csrf-token']");
    return csrfMetaTag ? csrfMetaTag.content : "";
  }

}
