'use strict';

var target = window;
target.addEventListener('routechange', function(event) {
  console.log('routechange');
  console.log(event);
});

target = document.querySelector('[data-view]');
target.addEventListener('viewcontentloaded', function(event) {
  console.log('viewcontentloaded');
  console.log(event);
});

target = document.body;
target.addEventListener('includecontentrequested', function(event) {
  console.log('includecontentrequested');
  console.log(event);
});

target.addEventListener('includecontentloaded', function(event) {
  console.log('includecontentloaded');
  console.log(event);
});

target.addEventListener('includecontenterror', function(event) {
  console.log('includecontenterror');
  console.log(event);
});
