'use strict';

route
  .when('/', {
    templateUrl: 'views/main.html',
    handler: Main
  })
  .when('/api', {
    redirectTo: '/api/Home'
  })
  .when('/api/:article', {
    templateUrl: 'views/api.html',
    handler: Api
  })
  .when('/tutorials/:article', {
    templateUrl: 'views/tutorials.html',
    handler: Tutorials
  })
  .when('/404', {
    templateUrl: 'views/404.html'
  })
  .otherwise('/404');
