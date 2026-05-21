import { Controller } from "@hotwired/stimulus";
import Card from "card";

// Renderiza la tarjeta animada (jessepollak/card) sobre el formulario de pago.
// La librería se sirve vía importmap desde vendor/javascript/card.js y, al
// importarse, inyecta sus propios estilos (.jp-card) mediante style-loader.
export default class extends Controller {
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
        expiry: "11/23",
        cvc: "123",
      },
    });

    // Dispara 'input' en los campos precargados para que la tarjeta refleje sus valores.
    this.element
      .querySelectorAll('input[name="number"], input[name="expiry"], input[name="cvc"]')
      .forEach((input) => {
        if (input.value && input.value.trim() !== "") {
          input.dispatchEvent(new Event("input", { bubbles: true }));
        }
      });
  }
}
