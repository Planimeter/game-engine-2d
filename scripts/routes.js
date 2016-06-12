route
  .when('/', {
    templateUrl: 'views/main.html',
    handler: function() {
      hljs.configure({ languages: ['Lua'] });
      var elements = document.querySelectorAll('pre code');
      Array.prototype.forEach.call(elements, function(block){
        hljs.highlightBlock(block);
      });
    }
  })
  .when('/api', {
    redirectTo: '/api/Home'
  })
  .when('/api/:article', {
    templateUrl: 'views/api.article.html',
  })
  .when('/404', {
    templateUrl: 'views/404.html'
  })
  .otherwise('/404');
