route
  .when('/', {
    templateUrl: 'views/main.html',
    handler: function() {
      hljs.configure({
        languages: ['lua']
      });

      var elements = document.querySelectorAll('pre code');
      Array.prototype.forEach.call(elements, function(el, i){
        hljs.highlightBlock(el);
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
