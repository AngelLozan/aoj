import { Controller } from "@hotwired/stimulus"
import { loadScript } from "@paypal/paypal-js";


export default class extends Controller {
  // paypal;

  async connect() {
    console.log("paypal controller connected");
    let paypal;

    try {
        paypal = await loadScript({ clientId: "AccNOO58_WwdjzmEecpOcp7GN38vgmVjw17Pb1agIdsUIw4Yqb4w1mwGOTsTgQ3Dsqz1Qc9QjY3KKqhM" });
    } catch (error) {
        console.error("failed to load the PayPal JS SDK script", error);
    }

    if (paypal) {
        try {
            await paypal.Buttons().render("#paypal-button-container");
        } catch (error) {
            console.error("failed to render the PayPal Buttons", error);
        }
  }
    // loadScript({
    //   "client-id": "sb",
    //   "currency": "USD"
    // }).then((paypal) => {
    //   paypal.Buttons().render(this.element)
    // })
  }
}
