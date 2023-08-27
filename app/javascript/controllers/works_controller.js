import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="works"
export default class extends Controller {

  connect() {
    console.log("Connected works controller");
  }

  openPainting(e) {
    console.log("Open painting");
    const painting = e.currentTarget;
    const url = painting.getAttribute("data-url");
    window.location.href = url;
  }


}
