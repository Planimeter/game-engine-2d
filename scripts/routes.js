'use strict';

route
  .when('/', {
    templateUrl: 'views/main.html',
    handler: Main
  })
  .when('/features', {
    templateUrl: 'views/features.html'
  })
  .when('/tutorials', {
    redirectTo: '/tutorials/Getting_Started'
  })
  .when('/tutorials/:article', {
    templateUrl: 'views/tutorials.html',
    handler: Article
  })
  .when('/api', {
    redirectTo: '/api/Home'
  })
  .when('/api/:article', {
    templateUrl: 'views/api.html',
    handler: Article
  })
  .when('/roadmap', {
    templateUrl: 'views/roadmap.html'
  })
  .when('/404', {
    templateUrl: 'views/404.html'
  })
  .otherwise('/404');
