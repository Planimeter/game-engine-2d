(function() {
  function navItem(element) {
    var routeName = route.pathname;
    var link      = element.querySelector('a');
    var href      = link.dataset['href-match'] ||
                    link.getAttribute('href')  ||
                    '';
    if ((routeName === href) ||
        (href !== '.' && routeName.lastIndexOf(href, 0) === 0)) {
      // set active nav link
      element.classList.add('active');

      // set nav title
      var navTitle = document.getElementById('nav-title');
      if (navTitle) {
        navTitle.textContent = link.title;
      }
    } else {
      element.classList.remove('active');
    }
  }

  function navItemAll() {
    var elements = document.querySelectorAll('.nav-item');
    for (var i = 0; i < elements.length; i++) {
      navItem(elements[i]);
    }
  }

  function ready(fn) {
    if (document.readyState != 'loading'){
      fn();
    } else {
      document.addEventListener('DOMContentLoaded', fn);
    }
  }

  ready(navItemAll);

  document.body.addEventListener('includecontentloaded', navItemAll);
})();
