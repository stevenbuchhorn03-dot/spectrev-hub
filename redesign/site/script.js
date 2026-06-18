/* Faktor M Consulting GmbH — Website-Skripte (vanilla JS, keine Abhängigkeiten) */
(function () {
  "use strict";

  /* ---------- Jahr im Footer ---------- */
  var yearEl = document.getElementById("year");
  if (yearEl) yearEl.textContent = new Date().getFullYear();

  /* ---------- Mobile-Navigation ---------- */
  var navToggle = document.getElementById("navToggle");
  var nav = document.getElementById("nav");
  if (navToggle && nav) {
    navToggle.addEventListener("click", function () {
      var open = nav.classList.toggle("is-open");
      navToggle.setAttribute("aria-expanded", open ? "true" : "false");
      navToggle.setAttribute("aria-label", open ? "Menü schließen" : "Menü öffnen");
    });
    nav.addEventListener("click", function (e) {
      if (e.target.tagName === "A" && nav.classList.contains("is-open")) {
        nav.classList.remove("is-open");
        navToggle.setAttribute("aria-expanded", "false");
      }
    });
  }

  /* ---------- Tabs: Unternehmen / Bewerber ---------- */
  var tabs = [
    { tab: "tab-unternehmen", panel: "panel-unternehmen" },
    { tab: "tab-bewerber", panel: "panel-bewerber" }
  ];
  function activate(activeId) {
    tabs.forEach(function (t) {
      var tabEl = document.getElementById(t.tab);
      var panelEl = document.getElementById(t.panel);
      if (!tabEl || !panelEl) return;
      var isActive = t.tab === activeId;
      tabEl.classList.toggle("is-active", isActive);
      tabEl.setAttribute("aria-selected", isActive ? "true" : "false");
      panelEl.classList.toggle("is-hidden", !isActive);
    });
  }
  tabs.forEach(function (t) {
    var tabEl = document.getElementById(t.tab);
    if (tabEl) tabEl.addEventListener("click", function () { activate(t.tab); });
  });
  // Direkt-Links #unternehmen / #bewerber sollen den passenden Tab öffnen
  function syncTabFromHash() {
    if (location.hash === "#bewerber") activate("tab-bewerber");
    else if (location.hash === "#unternehmen") activate("tab-unternehmen");
  }
  window.addEventListener("hashchange", syncTabFromHash);
  document.querySelectorAll('a[href="#bewerber"]').forEach(function (a) {
    a.addEventListener("click", function () { activate("tab-bewerber"); });
  });
  document.querySelectorAll('a[href="#unternehmen"]').forEach(function (a) {
    a.addEventListener("click", function () { activate("tab-unternehmen"); });
  });
  syncTabFromHash();

  /* ---------- Team aus Daten rendern ---------- */
  var team = [
    { name: "Jan-Philip Stender", role: "Geschäftsführender Gesellschafter", tel: "02734 47977-12" },
    { name: "Eduard Christiani", role: "Geschäftsführender Gesellschafter", tel: "02734 47977-13" },
    { name: "Jan Plaum", role: "Geschäftsführender Gesellschafter", tel: "02734 47977-11" },
    { name: "Chris Röhrig", role: "Personalberater", tel: "02734 47977-18" },
    { name: "Marek Studzinski", role: "Personalberater", tel: "02734 47977-19" },
    { name: "Melanie Neu", role: "Personalberaterin", tel: "02734 47977-15" },
    { name: "Sarah Schulz", role: "Personalberaterin", tel: "02734 47977-21" },
    { name: "Lilia Bazga", role: "Backoffice", tel: "02734 47977-22" },
    { name: "Irina Homrighausen", role: "Backoffice", tel: "02734 47977-16" }
  ];
  function initials(name) {
    return name.split(" ").map(function (p) { return p.charAt(0); }).join("").slice(0, 2).toUpperCase();
  }
  function telLink(tel) { return "tel:+49" + tel.replace(/[^0-9]/g, "").replace(/^0/, ""); }
  var teamGrid = document.querySelector(".team__grid");
  if (teamGrid) {
    var html = team.map(function (m) {
      return '<article class="member">' +
        '<div class="member__avatar" aria-hidden="true">' + initials(m.name) + '</div>' +
        '<h3>' + m.name + '</h3>' +
        '<p class="member__role">' + m.role + '</p>' +
        '<p class="member__contact"><a href="' + telLink(m.tel) + '">' + m.tel + '</a><br>' +
        '<a href="mailto:info@faktor-m.net">info@faktor-m.net</a></p>' +
        '</article>';
    }).join("");
    teamGrid.insertAdjacentHTML("afterbegin", html);
  }

  /* ---------- Kontaktformular ---------- */
  var form = document.getElementById("contactForm");
  var note = document.getElementById("formNote");
  if (form && note) {
    form.addEventListener("submit", function (e) {
      e.preventDefault();
      if (!form.checkValidity()) {
        note.textContent = "Bitte füllen Sie alle Pflichtfelder (*) aus.";
        note.className = "form-note is-err";
        form.reportValidity();
        return;
      }
      var vorname = form.querySelector('[name="vorname"]').value.trim();
      note.textContent = "Vielen Dank" + (vorname ? ", " + vorname : "") +
        "! Ihre Nachricht wurde übermittelt. Wir melden uns persönlich bei Ihnen.";
      note.className = "form-note is-ok";
      form.reset();
    });
  }

  /* ---------- Scroll-Reveal ---------- */
  var revealEls = document.querySelectorAll(
    ".path-card, .card, .step, .job, .news-card, .stats li, .section-head, .about__text, .contact__form, .member"
  );
  revealEls.forEach(function (el) { el.classList.add("reveal"); });
  if ("IntersectionObserver" in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12 });
    revealEls.forEach(function (el) { io.observe(el); });
    // Sicherheitsnetz: Inhalte dürfen nie dauerhaft unsichtbar bleiben
    window.setTimeout(function () {
      revealEls.forEach(function (el) { el.classList.add("is-visible"); });
    }, 2500);
  } else {
    revealEls.forEach(function (el) { el.classList.add("is-visible"); });
  }
})();
