import hljs from "highlight.js";

function applyHighlight() {
  for (const block of document.querySelectorAll("pre code")) {
    block.classList.remove("hljs");
    delete block.dataset.highlighted;

    hljs.highlightElement(block);
  }
}

document.addEventListener("DOMContentLoaded", function () {
  applyHighlight();
});

document.addEventListener("turbo:load", function () {
  applyHighlight();
});

document.addEventListener("turbo:render", function () {
  applyHighlight();
});
