import hljs from "highlight.js";

function applyHighlight() {
  for (const block of document.querySelectorAll("pre code")) {
    block.classList.remove("hljs");
    delete block.dataset.highlighted;

    hljs.highlightElement(block);
  }
}

// Para carga inicial (sin Turbo)
document.addEventListener("DOMContentLoaded", function () {
  applyHighlight();
});

// Para navegación con Turbo
document.addEventListener("turbo:load", function () {
  applyHighlight();
});

// Para cuando Turbo renderiza
document.addEventListener("turbo:render", function () {
  applyHighlight();
});
