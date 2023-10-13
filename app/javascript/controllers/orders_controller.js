import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    console.log("Connected orders controller");
  }

  openOrder(e) {
    console.log("Open order");
    const order = e.currentTarget;
    const url = order.getAttribute("data-url");
    window.location.href = url;
  }

}
