import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = [ "wrapper"];

  connect() {
    console.log("Cookie controller connected");
    if (document.cookie.includes('AOJ')) {
      return;
    } else {
      this.wrapperTarget.classList.remove('hidden');
      this.wrapperTarget.classList.add('show');
    }
  }

  accept() {
    this.wrapperTarget.classList.add('hidden');
    document.cookie = "cookieBy= AOJ; max-age=" + 60 * 60 * 24 * 30;
  }

  // reject() {
  //   this.wrapperTarget.classList.add('hidden');
  //   this.setCookie('cookie_consent', false, 365);
  // }

  // setCookie(name, value, days) {
  //   const expires = new Date();
  //   expires.setTime(expires.getTime() + days * 24 * 60 * 60 * 1000);
  //   document.cookie = `${name}=${value}; expires=${expires.toUTCString()}; path=/`;
  // }
}
