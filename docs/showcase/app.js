(function () {
  const progress = document.querySelector(".scroll-progress span");
  const updateProgress = () => {
    const max = document.documentElement.scrollHeight - window.innerHeight;
    const ratio = max > 0 ? window.scrollY / max : 0;
    if (window.gsap) {
      gsap.to(progress, { scaleX: ratio, duration: 0.16, ease: "power1.out", overwrite: true });
    } else {
      progress.style.transform = `scaleX(${ratio})`;
    }
  };
  updateProgress();
  window.addEventListener("scroll", updateProgress, { passive: true });

  if (!window.gsap) {
    document.documentElement.classList.add("no-gsap");
    return;
  }

  document.documentElement.classList.add("gsap-ready");
  gsap.defaults({ duration: 0.8, ease: "power3.out" });

  const mm = gsap.matchMedia();
  mm.add(
    {
      isDesktop: "(min-width: 900px)",
      reduceMotion: "(prefers-reduced-motion: reduce)"
    },
    (context) => {
      const { isDesktop, reduceMotion } = context.conditions;
      if (reduceMotion) return;

      const intro = gsap.timeline({ defaults: { ease: "power3.out" } });
      intro
        .from(".site-nav", { y: -18, autoAlpha: 0, duration: 0.75 })
        .from(".hero-bg", { scale: 1.12, duration: 1.5 }, 0)
        .from(".hero-copy .eyebrow", { y: 18, autoAlpha: 0 }, 0.2)
        .from(".hero h1", { y: 46, autoAlpha: 0, duration: 1.05 }, 0.32)
        .from(".latin", { y: 22, autoAlpha: 0 }, 0.56)
        .from(".hero-line", { y: 26, autoAlpha: 0 }, 0.72)
        .from(".collector", { x: isDesktop ? 58 : 24, y: 28, autoAlpha: 0, duration: 1.25 }, 0.38)
        .from(".echo-figure", { y: 34, autoAlpha: 0, duration: 1 }, 0.68)
        .from(".hero-meta span", { y: 18, autoAlpha: 0, stagger: 0.08 }, 0.95);

      gsap.to(".collector", {
        y: -12,
        duration: 3.4,
        repeat: -1,
        yoyo: true,
        ease: "sine.inOut"
      });
      gsap.to(".echo-figure", {
        y: 10,
        duration: 2.6,
        repeat: -1,
        yoyo: true,
        ease: "sine.inOut"
      });
      gsap.to(".die", {
        y: (i) => [-10, 8, -14][i] || -8,
        rotation: (i) => [10, -8, 14][i] || 8,
        duration: 1.8,
        repeat: -1,
        yoyo: true,
        stagger: 0.18,
        ease: "sine.inOut"
      });
    }
  );

  const revealTargets = document.querySelectorAll("[data-reveal]");
  gsap.set(revealTargets, { autoAlpha: 0, y: 34 });
  const revealObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        gsap.to(entry.target, { autoAlpha: 1, y: 0, duration: 0.85, overwrite: true });
        revealObserver.unobserve(entry.target);
      });
    },
    { threshold: 0.18, rootMargin: "0px 0px -8% 0px" }
  );
  revealTargets.forEach((target) => revealObserver.observe(target));

  document.querySelectorAll(".cast-card").forEach((card) => {
    card.addEventListener("mouseenter", () => {
      document.querySelectorAll(".cast-card").forEach((item) => item.classList.remove("is-active"));
      card.classList.add("is-active");
      gsap.to(card, { y: -8, duration: 0.28, overwrite: true });
    });
    card.addEventListener("mouseleave", () => {
      gsap.to(card, { y: 0, duration: 0.34, overwrite: true });
    });
  });

  document.querySelectorAll(".hero, .field-cinema, .dice-card").forEach((zone) => {
    zone.addEventListener("pointermove", (event) => {
      const rect = zone.getBoundingClientRect();
      const x = (event.clientX - rect.left) / rect.width - 0.5;
      const y = (event.clientY - rect.top) / rect.height - 0.5;
      gsap.to(zone.querySelectorAll("img"), {
        x: (index) => x * (index + 1) * 8,
        y: (index) => y * (index + 1) * 6,
        duration: 0.55,
        ease: "power2.out",
        overwrite: true
      });
    });
    zone.addEventListener("pointerleave", () => {
      gsap.to(zone.querySelectorAll("img"), {
        x: 0,
        y: 0,
        duration: 0.75,
        ease: "power2.out",
        overwrite: true
      });
    });
  });
})();
