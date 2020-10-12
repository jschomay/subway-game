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

////////////////////
//PERSIST STATE

const persistPrefix = "persist-";

app.ports.persistListReq.subscribe(() => {
  let saves = Object.entries(localStorage)
    .filter(([k, v]) => k.startsWith(persistPrefix))
    .sort(
      ([k1, v1], [k2, v2]) =>
        JSON.parse(v2).timestamp - JSON.parse(v1).timestamp
    )
    .map(([k, v]) => k.slice(persistPrefix.length));
  app.ports.persistListRes.send([new Date().toUTCString(), saves]);
});

app.ports.persistLoadReq.subscribe((key) => {
  let { history } = JSON.parse(localStorage.getItem(persistPrefix + key)) || {
    history: []
  };
  if (history) setTimeout(() => app.ports.persistLoadRes.send(history), 100);
});

app.ports.persistSaveReq.subscribe(([key, value]) => {
  localStorage.setItem(
    persistPrefix + key,
    JSON.stringify({ timestamp: Date.now(), history: value })
  );
  app.ports.persistListChanged.send(null);
});

app.ports.persistDeleteReq.subscribe((key) => {
  localStorage.removeItem(persistPrefix + key);
  app.ports.persistListChanged.send(null);
});

//////////////////
//PLAYING SOUNDS

app.ports.playSound.subscribe((key) => {
  // console.debug("playing", key, loadedSounds[key]);
  loadedSounds[key].play();
});

app.ports.stopSound.subscribe((key) => {
  // console.debug("stopping", key, loadedSounds[key]);
  loadedSounds[key]
    .fade(1, 0, 1000)
    .once("fade", () => loadedSounds[key].stop().volume(1));
});

//////////////////
//LOADING ASSETS

// TODO consider specifying only the images needed immediatly to load
var totalAssetsToLoad = 0;
var numAssetsLoaded = 0;
const progressBarEl = document.getElementById("loading-progress");
function assetLoaded() {
  numAssetsLoaded++;
  progressBarEl.value = numAssetsLoaded / totalAssetsToLoad;
  progressBarEl.innerText = numAssetsLoaded / totalAssetsToLoad;
  if (numAssetsLoaded === totalAssetsToLoad) {
    loaded();
  } else {
    // console.log(`loaded ${numAssetsLoaded} of ${totalAssetsToLoad} assets`);
  }
}

function loaded() {
  app.ports.loaded.send(true);
  console.log("all assets loaded");
}

///////
//images

var imagesToLoad = require.context("./img/", true, /\.*$/).keys();

// need to keep a reference so browsers don't dereference and lose the cache
var loadedImages = imagesToLoad.map(loadImage);

function loadImage(path) {
  totalAssetsToLoad++;
  var img = new Image();
  img.src = "img/" + path;
  img.onload = assetLoaded;
  console.log("loading image", img.src);
  return img;
}

/////
//audio

const loadedSounds = {};
const audoPrefix = "audio/";
const sounds = {
  piano2: { exts: ["mp3"], waitForLoad: true, loop: true },
  song: { exts: ["mp3", "ogg"], loop: true },
  song_long: { exts: ["mp3"], loop: true },
  subway_ambient_loop: {
    exts: ["wav"],
    waitForLoad: true,
    loop: true,
    volumn: 0.6
  },
  subway_arrival: { exts: ["wav"] },
  subway_departure: { exts: ["wav"], waitForLoad: true },
  subway_whistle: { exts: ["wav"], waitForLoad: true }
};

Object.entries(sounds).forEach(loadSound);

function loadSound([key, { waitForLoad, exts, loop }]) {
  if (waitForLoad) totalAssetsToLoad++;
  let sound = new Howl({
    src: exts.map((ext) => audoPrefix + key + "." + ext),
    loop: loop || false
  });
  if (waitForLoad) sound.once("load", assetLoaded);
  console.log("loading sound", key);
  loadedSounds[key] = sound;
}

////////////////////
//LISTENERS

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
