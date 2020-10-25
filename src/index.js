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
require("./styles/notebook.css");
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
////////////////////

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
//////////////////

app.ports.playSound.subscribe((key) => {
  // console.debug("playing", key, loadedSounds[key]);
  loadedSounds[key].play();
});

let loopTime, nextLoopKey, nextLoopIndex, currentLoopKey, currentLoopIndex;

const loopsPerSong = {
  "music/song2": 6
};

function getLoopKey() {
  return `${currentLoopKey}/loop${currentLoopIndex + 1}`;
}

function checkLoop() {
  if (Date.now() > loopTime) {
    playLoop();
  } else {
    requestAnimationFrame(checkLoop);
  }
}

app.ports.playMusic.subscribe(newSong);

function newSong(key) {
  nextLoopKey = key;
  nextLoopIndex = 0;
  if (
    currentLoopKey &&
    currentLoopIndex &&
    loadedSounds[getLoopKey()].playing()
  ) {
    // wait for next loop
    return;
  } else {
    playLoop();
  }
}

function playLoop() {
  currentLoopKey = nextLoopKey;
  currentLoopIndex = nextLoopIndex;
  let loop = getLoopKey();
  console.debug("playing loop", loop);
  // each loop transitions to it's "tail" 1/3 of the way through
  loopTime = loadedSounds[loop].duration() * 1000 * 0.66 + Date.now();
  loadedSounds[loop].play();
  requestAnimationFrame(checkLoop);
}

// changes the loop of the current song
app.ports.queueNextLoop.subscribe(
  () => (nextLoopIndex = (nextLoopIndex + 1) % loopsPerSong[currentLoopKey])
);

app.ports.stopSound.subscribe(stopSound);

function stopSound(key) {
  // console.debug("stopping", key, loadedSounds[key]);
  let v = loadedSounds[key].volume();
  loadedSounds[key]
    .fade(v, 0, 1000)
    .once("fade", () => loadedSounds[key].stop().volume(v));
}

app.ports.stopMusic.subscribe(() => {
  if (!currentLoopKey) return;
  let loop = getLoopKey();
  stopSound(loop);
});

let originalVolume;
app.ports.lowerMusicVolume.subscribe(() => {
  if (!currentLoopKey) return;
  let loop = getLoopKey();
  originalVolume = loadedSounds[loop].volume();
  // console.debug("lowering mustic volume", loop, originalVolume / 2);
  loadedSounds[loop].fade(originalVolume, originalVolume / 2, 1000);
});

app.ports.restoreMusicVolume.subscribe(() => {
  if (!currentLoopKey) return;
  let loop = getLoopKey();
  // console.debug("restore mustic volume", loop, originalVolume);
  let currentVolume = loadedSounds[loop].volume();
  loadedSounds[loop].fade(currentVolume, originalVolume, 1000);
});

//////////////////
//LOADING ASSETS
//////////////////

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
///////

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
/////

const loadedSounds = {};
const audoPrefix = "audio/";
const sounds = {
  "music/song1/piano2": { exts: ["mp3"], waitForLoad: true, loop: true },
  "music/song2/loop1": { exts: ["wav"] },
  "music/song2/loop2": { exts: ["wav"] },
  "music/song2/loop3": { exts: ["wav"] },
  "music/song2/loop4": { exts: ["wav"] },
  "music/song2/loop5": { exts: ["wav"] },
  "music/song2/loop6": { exts: ["wav"] },
  "sfx/subway_ambient_loop": {
    exts: ["wav"],
    waitForLoad: true,
    loop: true,
    volume: 0.4
  },
  "sfx/subway_arrival": { exts: ["wav"], volume: 0.7 },
  "sfx/subway_arrival2": { exts: ["wav"], waitForLoad: true },
  "sfx/subway_departure": { exts: ["wav"], waitForLoad: true },
  "sfx/subway_whistle": { exts: ["wav"], waitForLoad: true },
  "sfx/ambience_crowd_loop": {
    exts: ["ogg"],
    waitForLoad: true,
    loop: true,
    volume: 0.7
  }
};

Object.entries(sounds).forEach(loadSound);

function loadSound([key, { waitForLoad, exts, loop, volume }]) {
  if (waitForLoad) totalAssetsToLoad++;
  let sound = new Howl({
    src: exts.map((ext) => audoPrefix + key + "." + ext),
    loop: loop || false,
    volume: volume || 1
  });
  if (waitForLoad) sound.once("load", assetLoaded);
  console.log("loading sound", key);
  loadedSounds[key] = sound;
}

////////////////////
//LISTENERS
////////////////////

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
