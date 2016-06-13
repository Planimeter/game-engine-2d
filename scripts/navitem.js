(function() {
  'use strict';

  function navItem(element) {
    var routeName = route.pathname;
    var link      = element.querySelector('a');
    var href      = link.dataset.hrefMatch ||
                    link.getAttribute('href')  ||
                    '';
    if ((routeName === href) ||
        (href !== '.' && routeName.lastIndexOf(href, 0) === 0) ||
        (routeName === '/' && href === '.')) {
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

  var el = document.querySelector('[data-view]');
  el.addEventListener('viewcontentloaded', navItemAll);
})();
