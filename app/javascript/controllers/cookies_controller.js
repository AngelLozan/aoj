import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["wrapper"];

  connect() {
    console.log("Cookie controller connected");
    if (document.cookie.includes("AOJ")) {
      return;
    } else if (document.cookie.includes("cookie_consent")) {
      return;
    } else {
      this.wrapperTarget.classList.remove("hidden");
      this.wrapperTarget.classList.add("show");
    }
  }

  accept() {
    this.wrapperTarget.classList.add("hidden");
    document.cookie = "cookieBy= AOJ; max-age=" + 60 * 60 * 24 * 30;
  }

  reject() {
    this.wrapperTarget.classList.add("hidden");
    this.deleteCookies();
    this.setCookie('cookie_consent', false, 365);
  }

  deleteCookies() {
    let theCookies = document.cookie.split(";");
    for (var i = 0; i < theCookies.length; i++) {
      document.cookie =
        theCookies[i].split("=")[0] +
        "=; path=/; expires=Thu, 01 Jan 1970 00:00:01 GMT;";
    }
  }
  setCookie(name, value, days) {
    const expires = new Date();
    expires.setTime(expires.getTime() + days * 24 * 60 * 60 * 1000);
    document.cookie = `${name}=${value}; expires=${expires.toUTCString()}; path=/`;
  }
}
