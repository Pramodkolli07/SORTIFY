/* Sortify - small UX helpers (reveal animations + smooth CTA behaviors) */
(function () {
  const revealEls = Array.from(document.querySelectorAll("[data-reveal]"));
  if (revealEls.length) {
    const prefersReduced = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (!prefersReduced && "IntersectionObserver" in window) {
      const io = new IntersectionObserver(
        (entries) => {
          for (const e of entries) {
            if (e.isIntersecting) {
              e.target.classList.add("is-visible");
              io.unobserve(e.target);
            }
          }
        },
        { threshold: 0.12 }
      );
      for (const el of revealEls) io.observe(el);
    } else {
      for (const el of revealEls) el.classList.add("is-visible");
    }
  }

  // Smooth CTA: if user clicks a "Book a Cleanup" button, go to contact form.
  const ctas = Array.from(document.querySelectorAll('a[href^="contact.html"], a[data-cta="book"]'));
  for (const a of ctas) {
    a.addEventListener("click", (ev) => {
      const href = a.getAttribute("href") || "";
      // If it's already a hash on contact page, let it go through.
      if (href.includes("#")) return;
    });
  }

  // Contact form: create a mailto draft (no backend required).
  const form = document.getElementById("contactForm");
  if (!form) return;

  form.addEventListener("submit", (ev) => {
    ev.preventDefault();

    const name = (form.querySelector('input[name="name"]') || {}).value || "";
    const email = (form.querySelector('input[name="email"]') || {}).value || "";
    const phone = (form.querySelector('input[name="phone"]') || {}).value || "";
    const service = (form.querySelector('select[name="service"]') || {}).value || "Cleanup";
    const message = (form.querySelector('textarea[name="message"]') || {}).value || "";

    const to = "hello@sortify.com"; // Replace with your real email.
    const subject = `Sortify - Book a Cleanup (${service})`;

    const bodyLines = [
      `Name: ${name}`,
      `Email: ${email}`,
      `Phone: ${phone}`,
      `Service: ${service}`,
      "",
      "Message:",
      message,
    ];
    const body = bodyLines.join("\n");

    const url = `mailto:${encodeURIComponent(to)}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(
      body
    )}`;

    // Let the browser open the mail client.
    window.location.href = url;
  });
})();

