import { Controller } from "@hotwired/stimulus";
import Card from "card";

export default class CreditCardController extends Controller {
  connect() {
    const wrapper = this.element.querySelector(".card-wrapper");
    if (!wrapper) return;

    this.card = new Card({
      form: this.element.querySelector("#card-form"),
      container: wrapper,
      formSelectors: {
        number: 'input[name="number"]',
        name: 'input[name="name"]',
        expiry: 'input[name="expiry"]',
        cvc: 'input[name="cvc"]',
      },
      width: 300,
      formatting: true,
      messages: {
        valid: "válido\n",
      },
      placeholders: {
        number: "•••• •••• •••• ••••",
        name: "Nombre Completo",
        expiry: "MM/YY",
        cvc: "CVC",
      },
      defaults: {
        number: "4051 8856 0044 6623",
        name: "Nombre Completo",
        expiry: "11/27",
        cvc: "123",
      },
    });

    this.element
      .querySelectorAll('input[name="number"], input[name="expiry"], input[name="cvc"]')
      .forEach((input) => {
        if (input.value && input.value.trim() !== "") {
          input.dispatchEvent(new Event("input", { bubbles: true }));
        }
      });
  }
}
