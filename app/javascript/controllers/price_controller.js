import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['input'];

  connect() {
    console.log("Price controller connected");
  }

  submit(event) {
    event.preventDefault();
    console.log("Price controller submit");
    const formattedValue = this.inputTarget.value.replace(/[^\d.]/g, '');
    const centsValue = (parseFloat(formattedValue) * 100).toFixed(0);
    this.inputTarget.value = centsValue;

    event.target.submit();
  }
}
