const navbar = document.querySelector(".navbar");

setTimeout(() => {
  if (navbar.classList.contains("animate-start")) {
    navbar.classList.add("animate");
    navbar.classList.remove("animate-start");
  }
}, 3000);

document.addEventListener("wheel", () => {
  if (navbar.classList.contains("animate-start")) {
    navbar.classList.remove("animate-start");
    navbar.classList.add("fast");
  }
});

document.addEventListener("touchmove", () => {
  if (navbar.classList.contains("animate-start")) {
    navbar.classList.remove("animate-start");
    navbar.classList.add("fast");
  }
});
