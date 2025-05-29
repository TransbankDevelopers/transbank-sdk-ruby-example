import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.applyThemeFromLocalStorage();
  }

  toggleMenu(event) {
    event.preventDefault();
    const mobileSdContainer = document.querySelector(".tbk-sidebar-mobile");
    if (mobileSdContainer) {
      mobileSdContainer.classList.toggle("show");
    }
  }

  closeMenu(event) {
    event.preventDefault();
    const mobileSdContainer = document.querySelector(".tbk-sidebar-mobile");
    if (mobileSdContainer) {
      mobileSdContainer.classList.remove("show");
    }
  }

  applyThemeFromLocalStorage() {
    const theme = localStorage.getItem("theme");
    const root = document.documentElement;
    if (theme === "dark") {
      root.setAttribute("data-theme", "dark");
      root.classList.remove("light");
      root.classList.add("dark");
    } else {
      root.setAttribute("data-theme", "light");
      root.classList.remove("dark");
      root.classList.add("light");
    }
  }

  toggleTheme() {
    const root = document.documentElement;
    const currentTheme = localStorage.getItem("theme");

    if (currentTheme === "dark") {
      root.setAttribute("data-theme", "light");
      root.classList.remove("dark");
      root.classList.add("light");
      localStorage.setItem("theme", "light");
    } else {
      root.setAttribute("data-theme", "dark");
      root.classList.remove("light");
      root.classList.add("dark");
      localStorage.setItem("theme", "dark");
    }
  }
}
