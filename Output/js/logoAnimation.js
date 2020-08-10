const navbar = document.querySelector(".navbar");

setTimeout(() => {
    if (navbar.classList.contains("animate")) {
        navbar.classList.remove("animate");
    }
}, 3000);

document.addEventListener("wheel", () => {
    navbar.classList.remove("animate");
    navbar.classList.add("fast");
});

document.addEventListener("touchmove", () => {
    navbar.classList.remove("animate");
    navbar.classList.add("fast");
});
