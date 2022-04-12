document.addEventListener("DOMContentLoaded", function() {
    // Apply Carbon classes
    [...document.querySelectorAll('a[id^=social]')].forEach(element => element.classList.add('bx--btn', 'bx--btn--tertiary'));
    [...document.querySelectorAll('a:not([id^=social])')].forEach(element => element.classList.add('bx--link'));
    [...document.querySelectorAll('input[type="text"]'), ...document.querySelectorAll('input[type="password"]')].forEach(element => element.classList.add('bx--text-input'));
    [...document.querySelectorAll('*[type="submit"]')].forEach(element => element.classList.add('bx--btn', 'bx--btn--primary'));
    [...document.querySelectorAll('label:not([class*="checkbox"')].forEach(element => element.classList.add('bx--label'));
    [...document.querySelectorAll('span[id^=input-error]')].forEach(element => element.classList.add('bx--form-requirement'));
    [...document.querySelectorAll('form > div')].forEach(element => element.classList.add('bx--form-item'));
});

