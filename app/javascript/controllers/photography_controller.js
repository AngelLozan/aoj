import { Controller } from "@hotwired/stimulus"
// import Lightbox from 'stimulus-lightbox'

// Connects to data-controller="photography"
export default class extends Controller {
  connect() {
    console.log("connected photography controller");
  }
}
