import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    console.log("Connected admin controller");
  }

  openWork(e) {
    console.log("Open work");
    const work = e.currentTarget;
    const url = work.getAttribute("data-url");
    window.location.href = url;
  }


}
