let currentSlide = 0;

/**
* Changes the slide of the inputted slideshow to the inputted new slide
* @param {HTMLDivElement} slideshow - The slideshow element
* @param {number} newSlide - The new slides's index
* @param {number} currentSlide - The current slide's index
*/
function changeSlide(slideshow, newSlide, currentSlide) {
    const slides = slideshow.querySelectorAll(".slides .slide");
    const controls = slideshow.querySelectorAll(".controls .control");

    slides[currentSlide].classList.remove("active");
    slides[newSlide].classList.add("active");

    controls[currentSlide].classList.remove("active");
    controls[newSlide].classList.add("active");
}

/**
* Auto plays slides on the inputted slideshow
* @param {HTMLDivElement} slideshow - The slideshow element
*/
function autoPlay(slideshow) {
    const controls = slideshow.querySelectorAll(".controls .control");

    if (currentSlide + 1 < controls.length) {
        changeSlide(slideshow, currentSlide + 1, currentSlide);
        currentSlide++;
    } else {
        changeSlide(slideshow, 0, currentSlide);
        currentSlide = 0;
    }
}

const slideshows = document.querySelectorAll(".slideshow");

slideshows.forEach(slideshow => {
    const slides = slideshow.querySelectorAll(".slides .slide");
    const controls = Array.from(slides).map((_, i) => {
        const control = document.createElement("div");

        if (i === currentSlide) {
            control.classList.add("active");
        }

        control.classList.add("control");
        slideshow.querySelector(".controls").appendChild(control);

        return control;
    });

    if (!slides[currentSlide].classList.contains("active")) {
        autoPlay(slideshow);
    }
    
    let autoPlayInterval = setInterval(() => {
        autoPlay(slideshow);
    }, 5000);

    controls.forEach((control, i) => {
        control.addEventListener("click", () => {
            changeSlide(slideshow, i, currentSlide);
            currentSlide = i;

            clearInterval(autoPlayInterval);

            autoPlayInterval = setInterval(() => {
                autoPlay(slideshow);
            }, 5000);
        });
    });
});
