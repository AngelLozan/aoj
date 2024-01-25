import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="table"
export default class extends Controller {
  static targets = ['searchForm', 'input', 'url']

  connect() {
    console.log('search controller connected');
    console.log(this.searchFormTarget);
  }

  resetSearch(e) {
    e.preventDefault();
    this.searchFormTarget.reset();
    this.inputTarget.value = '';
    this.searchFormTarget.submit();
  }

  resetSearchPrints() {
    // this.searchFormTarget.reset();
    window.location.href = "/prints/index";
  }

  get searchFormTarget() {
    // return this.targets.find('searchForm');
    return document.querySelector('form[data-search-target="searchForm"]');
  }
}
