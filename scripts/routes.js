route
  .when('/', {
    templateUrl: 'views/main.html'
  })
  .when('/api', {
    templateUrl: 'views/api.html',
  })
  .when('/api/:article', {
    templateUrl: 'views/api.article.html',
  })
  .when('/404', {
    templateUrl: 'views/404.html'
  })
  .otherwise('/404');
