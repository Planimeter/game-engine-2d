'use strict';

var target = window;
target.addEventListener('routechange', function(event) {
  console.log('routechange');
});

target = document.querySelector('[data-view]');
target.addEventListener('viewcontentloaded', function(event) {
  console.log('viewcontentloaded');
});

target = document.body;
target.addEventListener('includecontentrequested', function(event) {
  console.log('includecontentrequested');
});

target.addEventListener('includecontentloaded', function(event) {
  console.log('includecontentloaded');
});

target.addEventListener('includecontenterror', function(event) {
  console.log('includecontenterror');
});
