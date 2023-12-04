import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="prints"
export default class extends Controller {
  connect() {
    console.log("Prints controller");
  }

  openProduct(e) {
    console.log("Open print");
    const painting = e.currentTarget;
    const url = painting.getAttribute("data-url");
    window.location.href = url;
  }
}
