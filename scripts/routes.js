'use strict';

route
  .when('/', {
    templateUrl: 'views/main.html',
    handler: Main
  })
  .when('/tutorials', {
    redirectTo: '/tutorials/Home'
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
  .when('/404', {
    templateUrl: 'views/404.html'
  })
  .otherwise('/404');
