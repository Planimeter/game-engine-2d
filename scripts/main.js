function Main() {
  hljs.configure({ languages: ['Lua'] });

  var elements = document.querySelectorAll('pre code');
  Array.prototype.forEach.call(elements, function(block){
    hljs.highlightBlock(block);
  });
}
