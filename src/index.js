if (btoa(localStorage.getItem("password")) !== "c3Vid2F5") {
  var pass = prompt("Please enter the password to play the demo.");
  if (btoa(pass) !== "c3Vid2F5") {
    alert("Sorry, incorrect password");
    throw "Wrong password";
  } else {
    localStorage.setItem("password", pass);
  }
}

require("./styles/reset.css");
require("./styles/effects.css");
require("./styles/story.css");
require("./styles/train.css");
require("./styles/platform.css");
require("./styles/lobby.css");
require("./styles/passageway.css");
require("./styles/turnstile.css");
require("./styles/guard-office.css");
require("./styles/goals.css");
require("./styles/game.css");

// inject bundled Elm app
const { Elm } = require("./Main.elm");
const debug = location.hash === "#debug";
const app = Elm.Main.init({
  node: document.getElementById("main"),
  flags: { debug: debug }
});

const persistPrefix = "persist-";

app.ports.persistListReq.subscribe(() => {
  let saves = (Object.keys(localStorage) || {})
    .filter((k) => k.startsWith(persistPrefix))
    .map((k) => k.slice(persistPrefix.length));
  app.ports.persistListRes.send([new Date().toUTCString(), saves]);
});

app.ports.persistLoadReq.subscribe((key) => {
  let history = JSON.parse(localStorage.getItem(persistPrefix + key) || "[]");
  setTimeout(() => app.ports.persistLoadRes.send(history), 100);
});

app.ports.persistSaveReq.subscribe(([key, value]) => {
  localStorage.setItem(persistPrefix + key, JSON.stringify(value));
  app.ports.persistSaveRes.send(null);
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
  if (e.target.tagName != "INPUT") {
    app.ports.keyPress.send(e.key);
  }
  if (e.key == " " || e.key === "Backspace") {
    if (e.target.tagName != "INPUT") {
      e.preventDefault();
    }
  }
});
