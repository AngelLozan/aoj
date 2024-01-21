import { Controller } from "@hotwired/stimulus";
import { loadScript } from "@paypal/paypal-js";

export default class extends Controller {

  async connect() {
    console.log("paypal controller connected");
    let paypal;

    try {
      paypal = await loadScript({
        clientId:
          "AccNOO58_WwdjzmEecpOcp7GN38vgmVjw17Pb1agIdsUIw4Yqb4w1mwGOTsTgQ3Dsqz1Qc9QjY3KKqhM",
        components: ["buttons", "marks", "messages"],
        currency: "USD",
      });
      console.log("loaded the PayPal JS SDK script");
    } catch (error) {
      console.error("failed to load the PayPal JS SDK script", error);
    }

    if (paypal) {
      try {
        // await paypal.Buttons().render("#paypal-button-container");
        await paypal.Buttons({
          env: 'sandbox', // Valid values are sandbox and live.
          createOrder: async () => {
           try {
            const form = document.querySelector('#order-form');
            const formData = new FormData(form);
            const response = await fetch('/create_paypal', {
                method: 'POST',
                headers: {
                  "X-CSRF-Token": this.csrfToken,
                },
                 body: formData,
              });
              const result = await response.json();
              console.log("Paypal order created: ", result.orderID);
              return result.orderID;
           } catch(e){
            console.log(e);
           }
          },
          onApprove: async (data) => {
            const form = document.querySelector('#order-form');
            const formAction = form.getAttribute('action');
            const formData = new FormData(form);
            formData.append('paypal_order_id', data.orderID);
            try {
              const response = await fetch(formAction, {
                method: 'POST',
                body: formData,
              });
              const result = await response.json();
              console.log("Paypal order approved: ", result);
              if (result.error) {
                this.displayFlashMessage("Something went wrong, please try again 🤔", 'warning');
              } else {
              form.reset();
              this.displayFlashMessage("Thank you for order, your painting will arrive soon.", 'info');
              setTimeout(() => {
                window.location.href = "/";
              }, 2000);
            }
            } catch(e){
              console.log(e);
              this.displayFlashMessage("Something went wrong, please try again 🤔", 'warning');
            }
          }
        }).render('#paypal-button-container');
        console.log("rendered the PayPal Buttons");
      } catch (error) {
        console.error("failed to render the PayPal Buttons", error);
      }
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
