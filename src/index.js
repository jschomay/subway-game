require( './styles/reset.css' );
require( './styles/story.css' );
require( './styles/train.css' );
require( './styles/subway.css' );
require( './styles/game.css' );

// inject bundled Elm app
const { Elm } = require('./Main.elm');
const app = Elm.Main.init({
  node: document.getElementById('main')
});


var imagesToLoad = require.context('./img/', true, /\.*$/).keys()


// start app right away if we don't need to load anything
if (!imagesToLoad.length) {
  loaded();
}


// need to keep a reference so browsers don't dereference and lose the cache
var loadedImages = imagesToLoad.map(loadImage);

var numAssetsLoaded = 0;
function assetLoaded() {
  numAssetsLoaded++;
  if(numAssetsLoaded === imagesToLoad.length) {
    loaded();
  }
}

function loadImage(path) {
  var img = new Image();
  img.src = "img/" + path;
  img.onload = assetLoaded;
  console.log("loading", img.src)
  return img;
}

function loaded() {
  app.ports.loaded.send(true);
  console.log("loaded")
}

