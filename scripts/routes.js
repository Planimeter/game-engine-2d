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
  .when('/404', {
    templateUrl: 'views/404.html'
  })
  .otherwise('/404');
