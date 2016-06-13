function Api() {
  var renderer = new marked.Renderer();

  renderer.list = function (body, ordered) {
    var type = ordered ? 'ol' : 'ul';
    return '<' + type + (type === 'ul' ? ' class="list-unstyled"' : '') + '>\n' +
      body +
    '</' + type + '>\n';
  };

  renderer.table = function (header, body) {
    return '<table class="table">\n'
      + '<thead>\n'
      + header
      + '</thead>\n'
      + '<tbody>\n'
      + body
      + '</tbody>\n'
      + '</table>\n';
  };

  renderer.em = function (text) {
    if (text === 'Client') {
      return '<span class="label label-client">Client</span>';
    }

    if (text === 'Server') {
      return '<span class="label label-server">Server</span>';
    }

    if (text === 'Shared') {
      return '<span class="label label-shared">Shared</span>';
    }

    if (text === 'Unimplemented') {
      return '<span class="label label-danger">Unimplemented</span>';
    }

    return '<em>' + text + '</em>';
  };

   function startsWith(haystack, needle) {
     return haystack.lastIndexOf(needle, 0) === 0;
   }

  renderer.link = function(href, title, text) {
    if (!startsWith(href, 'http://') &&
        !startsWith(href, 'https://')) {
      href = href.lastIndexOf('api/', 0) === 0 ? href : 'api/' + href;
    }

    var out = '<a href="' + href + '"';
    if (title) {
      out += ' title="' + title + '"';
    }
    out += '>' + text + '</a>';
    return out;
  };

  marked.setOptions({
    highlight: function (code) {
      return hljs.highlightAuto(code).value;
    },
    renderer: renderer
  });

  var request  = new XMLHttpRequest();
  var article  = route.params.article;
  var baseHref = 'https://raw.githubusercontent.com/wiki/Planimeter/grid-sdk/';
  var url      = baseHref + article + '.md';
  request.open('GET', url, true);

  function set(text) {
    document.getElementById('article').innerHTML = marked(text);
  }

  var wikiHref = 'https://github.com/Planimeter/grid-sdk/wiki/';
  function onerror() {
    set(
      '# Cannot GET /' + article + '.md\r\n' +
      '[New Page](' + wikiHref + article + ')'
    );
  }

  request.onload = function() {
    if (this.status >= 200 && this.status < 400) {
     var markdown = this.response;
     set(markdown);
    } else {
      onerror();
    }
  };

  request.onerror = onerror;

  request.send();
}
