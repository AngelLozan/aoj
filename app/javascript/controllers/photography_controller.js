import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="photography"
export default class extends Controller {
  static targets = [ "myModal", "img01", "caption", "close" ]

  connect() {
    console.log("connected Photography controller");
  }

  openModal(event) {
    event.preventDefault();
    const imageElement = event.currentTarget;
    const imageUrl = imageElement.getAttribute("data-url");

    this.myModalTarget.style.display = "block";
    this.img01Target.src = imageUrl;
    // this.captionTarget.innerHTML = this.data.get("caption");
  }

  closeModal() {
    this.myModalTarget.style.display = "none";
  }

}
