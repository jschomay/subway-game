// require( './styles/reset.css' );
// require( './styles/story.css' );
// require( './styles/train.css' );
// require( './styles/subway.css' );
// require( './styles/game.css' );
require("./styles/graph.css");

// inject bundled Elm app
const { Elm } = require("./RuleGraph.elm");
const app = Elm.RuleGraph.init({
  node: document.getElementById("main")
});

app.ports.drawGraph.subscribe(function(src) {
  setTimeout(function() {
    var graph = Viz(
      src,
      (options = {
        format: "svg",
        engine: "dot",
        scale: undefined,
        images: [],
        totalMemory: 16777216
      })
    );
    var parser = new DOMParser();
    var newGraph = parser.parseFromString(graph, "image/svg+xml");
    var containerEl = document.querySelector("#graph");
    var oldGraph = containerEl.firstChild;

    containerEl.replaceChild(newGraph.documentElement, oldGraph);

    // app.ports.loaded.send(true);
  });
}, 0);
