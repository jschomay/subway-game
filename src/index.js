require("./styles/reset.css");
require("./styles/effects.css");
require("./styles/story.css");
require("./styles/train.css");
require("./styles/platform.css");
require("./styles/lobby.css");
require("./styles/turnstile.css");
require("./styles/guard-office.css");
require("./styles/goals.css");
require("./styles/game.css");

// inject bundled Elm app
const {Elm} = require("./Main.elm");
const debug = location.hash === "#debug";
const app = Elm.Main.init({
  node: document.getElementById("main"),
  flags: {debug: debug}
});

var imagesToLoad = require.context("./img/", true, /\.*$/).keys();

// start app right away if we don't need to load anything
if (!imagesToLoad.length) {
  loaded();
}

// need to keep a reference so browsers don't dereference and lose the cache
var loadedImages = imagesToLoad.map(loadImage);

var numAssetsLoaded = 0;
function assetLoaded() {
  numAssetsLoaded++;
  if (numAssetsLoaded === imagesToLoad.length) {
    loaded();
  }
}

function loadImage(path) {
  var img = new Image();
  img.src = "img/" + path;
  img.onload = assetLoaded;
  console.log("loading", img.src);
  return img;
}

function loaded() {
  app.ports.loaded.send(true);
  console.log("loaded");
}

document.addEventListener("keydown", function (e) {
  app.ports.keyPress.send(e.key);
  if (e.key == " " || e.key === "Backspace") {
    if (e.target.tagName != "INPUT") e.preventDefault();
  }
});
