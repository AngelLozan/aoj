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
  // // @dev Not needed for now.
  // async publishPrint() {
  //   console.log("Publish print");
  //   try {
  //     let res = await fetch("/publish_print");
  //     if (!res.ok) throw new Error("Could not publish print");

  //     data = await res.text();
  //     this.displayFlashMessage(
  //       "Submitted this as published 👍 Please verify it is in Printify shop.",
  //       "info"
  //     );
  //   } catch (error) {
  //     console.log("Something went wrong publishing the print: ", error);
  //     this.displayFlashMessage(
  //       "Couldn't publish for some reason. Please try again. 🤔",
  //       "warning"
  //     );
  //   }
  // }

  // displayFlashMessage(message, type) {
  //   const flashElement = document.createElement("div");
  //   flashElement.className = `alert alert-${type} alert-dismissible fade show m-1`;
  //   flashElement.role = "alert";
  //   flashElement.setAttribute("data-controller", "flash");
  //   flashElement.textContent = message;

  //   const button = document.createElement("button");
  //   button.className = "btn-close";
  //   button.setAttribute("data-bs-dismiss", "alert");

  //   flashElement.appendChild(button);
  //   document.body.appendChild(flashElement);

  //   setTimeout(() => {
  //     flashElement.remove();
  //   }, 5000);
  // }

}
