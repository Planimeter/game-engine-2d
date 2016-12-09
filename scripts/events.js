'use strict';

var target = window;
target.addEventListener('routechange', function(event) {
  console.log('[Task] 3: routechange');
});

target = document.querySelector('[data-view]');
target.addEventListener('viewcontentloaded', function(event) {
  console.log('[Task] 2: viewcontentloaded');
});

function update(node) {
  if (node.dataset && node.dataset.include) {
    console.log('[Microtask] 1: childList mutation');
    return;
  }

  var childNodes = node.childNodes;
  for (var i = 0; i < childNodes.length; i++) {
    update(childNodes[i]);
  }
}

var observer = new MutationObserver(function(mutations) {
  mutations.forEach(function(mutation) {
    Array.prototype.forEach.call(mutation.addedNodes, update);
  });
});

observer.observe(document.body, { childList: true, subtree: true });

target = document.body;
target.addEventListener('includecontentrequested', function(event) {
  console.log('[Task] 4: includecontentrequested');
});

target.addEventListener('includecontentloaded', function(event) {
  console.log('[Task] 5: includecontentloaded');
});

target.addEventListener('includecontenterror', function(event) {
  console.log('[Task] 5: includecontenterror');
});
