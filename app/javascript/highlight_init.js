import hljs from "highlight.js";

document.addEventListener("turbo:render", function () {
  document.querySelectorAll("pre code").forEach((block) => {
    hljs.highlightElement(block);
  });
});

document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll("pre code").forEach((block) => {
    hljs.highlightElement(block);
  });
});
