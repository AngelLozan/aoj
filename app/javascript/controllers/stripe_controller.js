import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "inputs", "total", "id", "remove", "add"]
  static values = {
    publishableKey: String,
  }

  formSubmitListener = null;


  async connect() {
    console.log("Connected stripe controller");
    this.setupFormListener();
    // this.itemListeners();
  }

  // @dev Ensures form elements full before executing button listener for quantity update.
  async checkFormElements() {
    console.log("Checking form elements");
    let missingOne = false; //@dev Form is filled out unless found otherwise below.
    const formElements = this.formTarget.elements;
    for (let i = 0; i < formElements.length; i++) {
      const element = formElements[i];
      if (element.value === "" && element.type !== "hidden" && element.classList.contains('required')) {
        missingOne = true;
        break;
      }
  }
  console.log("Missing one: ", missingOne);
  return missingOne;
}


  async setupFormListener() {
    console.log("Setting up form listener");

    this.formSubmitListener = async (event) => {
      event.preventDefault();
      let orderId = '';
      let call = await this.checkFormElements()
      try {
        if (call) {
          this.displayFlashMessage("Please fill all required form fields 🙏", 'warning');
          return;
        } else {
          const [amount, stripeOrderId] = await this.amount();
          orderId = stripeOrderId;
          await this.initializeStripe(amount, stripeOrderId);
          if (stripeOrderId !== '') {
            await this.handleStripeClosed();
          }
          await this.loadStripeScript();
        }

      } catch (error) {
        console.log("Error in form listener: ", error.message);
        if (orderId !== '') {
          await this.handleStripeClosed();
        }
      }
    };

    this.formTarget.addEventListener("submit", this.formSubmitListener);
  }

  async handleStripeClosed() {
    console.log("Cancelling print order used to get shipping price");

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
        console.log("Successfully cancelled mock print order");
      }
    } catch (error) {
      console.log("Error cancelling shipping: ", error.message);
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
      this.displayFlashMessage("Something went wrong, please try again 🤔", 'warning');
    }
  }

  get csrfToken() {
    const csrfMetaTag = document.querySelector("meta[name='csrf-token']");
    return csrfMetaTag ? csrfMetaTag.content : "";
  }

  displayFlashMessage(message, type) {
    const flashElement = document.createElement('div');
    flashElement.className = `alert alert-${type} alert-dismissible fade show m-1`;
    flashElement.role = 'alert';
    flashElement.setAttribute('data-controller', 'flash');
    flashElement.textContent = message;

    const button = document.createElement('button');
    button.className = 'btn-close';
    button.setAttribute('data-bs-dismiss', 'alert');

    flashElement.appendChild(button);
    document.body.appendChild(flashElement);

    setTimeout(() => {
        flashElement.remove();
    }, 5000);
}

}
