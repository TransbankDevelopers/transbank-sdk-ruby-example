import hljs from "highlight.js";

document.addEventListener("turbo:render", function () {
  console.log("test");

  document.querySelectorAll("pre code").forEach((block) => {
    hljs.highlightElement(block);
  });
});

document.addEventListener("DOMContentLoaded", function () {
  console.log("Hola");
  document.querySelectorAll("pre code").forEach((block) => {
    hljs.highlightElement(block);
  });
});
