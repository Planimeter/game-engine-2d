'use strict';

document.body.addEventListener('includecontentloaded', function(event) {
  var el = event.target;
  if (el.dataset.marked === '') {
    el.innerHTML = marked(el.innerHTML);
  };
});
