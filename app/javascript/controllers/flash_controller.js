import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    console.log('Flash controller present');
    setTimeout(() => {
      this.dismiss();
    }, 8000);
  }

  dismiss() {
    this.element.remove();
  }
}
