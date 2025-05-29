import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "toggleButton",
    "sidebar",
    "collapsibleTitle",
    "arrow",
    "collapsibleContent",
    "sidebarItem",
  ];

  connect() {
    console.log("Sidebar controller connected");
    this.isMenuVisible = true;
    this.bodyContainer = document.querySelector(".body-container");
    console.log(this.bodyContainer);

    this.highlightActiveByUrl();
  }

  toggleSidebar() {
    this.isMenuVisible = !this.isMenuVisible;
    if (!this.isMenuVisible) {
      this.sidebarTarget.classList.add("tbk-sidebar-hide");
      if (this.bodyContainer) {
        this.bodyContainer.classList.add("hide-sd");
      }
    } else {
      this.sidebarTarget.classList.remove("tbk-sidebar-hide");
      if (this.bodyContainer) {
        this.bodyContainer.classList.remove("hide-sd");
      }
    }
  }

  toggleCollapsible(event) {
    const titleButton = event.currentTarget;
    // The content is the next sibling element (the <ul>)
    const content = titleButton.nextElementSibling;
    const arrow = titleButton.querySelector(".arrow");

    if (!content) {
      console.warn("Collapsible content not found for:", titleButton);
      return;
    }

    content.classList.toggle("open");
    if (arrow) {
      // Check if arrow exists before toggling class
      arrow.classList.toggle("sidebar-icons-rotate");
    }
  }

  highlightActiveByUrl() {
    const currentPath = window.location.pathname;
    const principalPath = currentPath.split("/")[1];

    this.sidebarItemTargets.forEach((anchor) => {
      const linkPath = anchor.getAttribute("href") || "";
      const principalLinkPath = linkPath.split("/")[1];

      const isActive =
        currentPath === linkPath ||
        (principalPath && principalPath === principalLinkPath);

      if (isActive) {
        this.highlightActiveItem(anchor);
      }
    });
  }

  highlightActiveItem(anchor) {
    const liItem = anchor.closest("li.collapsible-items");
    if (!liItem) return;

    liItem.classList.add("active");
    const collapsibleUl = liItem.closest(".collapsible-content");
    if (!collapsibleUl) return;

    collapsibleUl.classList.add("open");
    const collapsibleButton = collapsibleUl.previousElementSibling;
    if (!collapsibleButton) return;

    const icon = collapsibleButton.querySelector("img.arrow");
    if (icon) icon.classList.add("sidebar-icons-rotate");
  }
}
