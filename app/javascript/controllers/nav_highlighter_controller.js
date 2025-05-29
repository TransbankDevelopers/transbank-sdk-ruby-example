import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["link"];

  connect() {
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            this.clearActiveClasses();
            const targetLink = this.linkTargets.find(
              (link) => link.getAttribute("href") === `#${entry.target.id}`
            );
            if (targetLink) {
              targetLink.classList.add("active");
            }
          }
        });
      },
      {
        rootMargin: "0px 0px -70% 0px",
      }
    );

    this.linkTargets.forEach((link) => {
      const targetId = link.getAttribute("href");
      const targetElement = document.querySelector(targetId);
      if (targetElement) {
        this.observer.observe(targetElement);
      }
    });
  }

  disconnect() {
    this.observer.disconnect();
  }

  clearActiveClasses() {
    this.linkTargets.forEach((link) => {
      link.classList.remove("active");
    });
  }
}
