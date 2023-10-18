// Define your Stimulus controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["topBtn"];

  connect() {
    // Add a scroll event listener when the controller connects
    window.addEventListener("scroll", this.scrollFunction.bind(this));
  }

  disconnect() {
    // Remove the scroll event listener when the controller disconnects
    window.removeEventListener("scroll", this.scrollFunction.bind(this));
  }

  scrollFunction() {
    const button = this.topBtnTarget;
    if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
      button.style.display = "block";
    } else {
      button.style.display = "none";
    }
  }

  scrollToTop() {
    // When the button is clicked, scroll to the top of the document
    document.body.scrollTop = 0; // For Safari
    document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE, and Opera
  }
}
