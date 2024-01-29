import { Controller } from "@hotwired/stimulus";
import { loadScript } from "@paypal/paypal-js";

export default class extends Controller {
  static targets = ["id"];

  async connect() {
    console.log("paypal controller connected");
    let paypal;

    try {
      paypal = await loadScript({
        clientId:
          // "AXxF9LZQ1pC0oCdiQFiz7UtpRifxqtehKJIAZw0D-3Nj7o0SeKrB12XyzxDPWe3S-v1FYdO_O_yNK1VZ", // Live
          "AccNOO58_WwdjzmEecpOcp7GN38vgmVjw17Pb1agIdsUIw4Yqb4w1mwGOTsTgQ3Dsqz1Qc9QjY3KKqhM", // Sandbox
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
            const call = await this.checkFormElements()
            if (call) {
              this.displayFlashMessage("Please fill all required form fields 🙏", 'warning');
              return;
            }
            const response = await fetch('/create_paypal', {
                method: 'POST',
                headers: {
                  "X-CSRF-Token": this.csrfToken,
                },
                 body: formData,
              });
              const result = await response.json();
              console.log("Paypal order created: ", result.orderID);
              // return result.orderID;
              this.idTarget.value = result.paypal_order_id; //@dev is printify order id for cancel.
              return result.orderID;
           } catch(e){
            console.log(e);
            this.displayFlashMessage("Something went wrong, please try again 🤔", 'warning');
           }
          },
          onCancel: async (data) => {
            const orderID = data.orderID;
            // const paypalOrderID = data[1]; //@dev is printify order id
            // this.idTarget.value = paypalOrderID; //@dev is printify order id for cancel.
            console.log("Will cancel Paypal order: ", orderID);
            try {
              await this.handleModalClosed();
            } catch (error) {
              console.log("Error cancelling print order: ", error.message);
            }
          },
          onApprove: async (data) => {
            const form = document.querySelector('#order-form');
            const formAction = form.getAttribute('action');
            const formData = new FormData(form);
            // formData.append('paypal_order_id', data.orderID);
            formData.append('paypal_order_id', data.orderID); //@dev is paypals internal id
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
                this.displayFlashMessage("Thanks for supporting art! 🎊 Your order will arrive soon.", 'info');
                setTimeout(() => {
                  window.location.href = "/paintings";
                }, 1000);
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
        location.reload();
        // this.displayFlashMessage("Something went wrong, please refresh the page 🤔", 'warning');
      }
    }
  }

  // async handleModalClosed() {
  //   console.log("Cancelling print order used to get shipping price");
  //   const form = document.querySelector('#order-form');
  //   try {
  //     let res = await fetch(`/cancel_print_order`, {
  //       method: "POST",
  //       headers: {
  //         Accept: "application/json",
  //         "X-CSRF-Token": this.csrfToken,
  //       },
  //       body: new FormData(form),
  //     });
  //     let response = await res.json();
  //     console.log("RESPONSE:", response);
  //     if (response.status === "success") {
  //       console.log("Successfully cancelled print order");
  //     } else {
  //       this.displayFlashMessage("Something went wrong, please refresh the page 🤔", 'warning');
  //     }
  //   } catch (error) {
  //     console.log("Error cancelling shipping: ", error.message);
  //   }

  // }

  async handleModalClosed() {
    console.log("Cancelling print order used to get shipping price");
    const form = document.querySelector('#order-form');

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
          await new Promise(resolve => setTimeout(resolve, 1000));
        }
      } catch (error) {
        console.log("Error cancelling shipping: ", error.message);
      }
    }

    if (!success) {
      console.log("Operation timed out after 30 seconds");
      // Handle the case when the operation times out
    }
  }


  async checkFormElements() {
    console.log("Checking form elements");
    let missingOne = false; //@dev Form is filled out unless found otherwise below.
    const form = document.querySelector('#order-form');
    const formElements = form.elements;
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
