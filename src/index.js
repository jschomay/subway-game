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
import { InworldClient } from "@inworld/web-sdk";

// inject bundled Elm app
const { Elm } = require("./Main.elm");
const debug = location.hash === "#debug";
const app = Elm.Main.init({
  node: document.getElementById("main"),
  flags: { debug: debug },
});

// get trains image (used for loading loaded) ready as soon as possible
var loadingScreenImage = new Image();
loadingScreenImage.src = "img/riding-train.jpg";

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
    history: [],
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

let loopStart,
  currentLoop,
  nextLoop,
  dramaVolume = 0;
const loopLengths = { 1: 80000, 2: 80000, 3: 80000, 4: 50000 };

function checkLoop() {
  if (Date.now() > loopStart + loopLengths[currentLoop]) {
    loop();
  } else {
    requestAnimationFrame(checkLoop);
  }
}

app.ports.queueLoopReq.subscribe((key) => {
  // console.log("queue", key);
  nextLoop = key;
  if (!currentLoop) loop();
});

function loop() {
  if (currentLoop !== nextLoop) dramaVolume = 0;
  currentLoop = nextLoop;
  // console.debug("playing loop", currentLoop);

  loadedSounds[`music/${currentLoop}l`].play();
  loadedSounds[`music/${currentLoop}d`].volume(dramaVolume);
  loadedSounds[`music/${currentLoop}d`].play();
  loopStart = Date.now();
  requestAnimationFrame(checkLoop);
}

app.ports.stopSound.subscribe((key) => {
  // console.debug("stopping", key, loadedSounds[key]);
  let v = loadedSounds[key].volume();
  loadedSounds[key]
    .fade(v, 0, 1000)
    .once("fade", () => loadedSounds[key].stop().volume(v));
});

app.ports.stopMusic.subscribe(() => {
  if (!currentLoop) return;
  // console.debug("stopping music", currentLoop);
  loadedSounds[`music/${currentLoop}l`].stop();
  loadedSounds[`music/${currentLoop}d`].stop();
  loadedSounds[`music/${currentLoop}d`].volume(0);
  dramaVolume = 0;
  currentLoop = null;
  nextLoop = null;
  loopStart = null;
});

app.ports.addDramaReq.subscribe(() => {
  if (!currentLoop) return;
  // console.debug("adding drama", currentLoop);
  dramaVolume = 1;
  loadedSounds[`music/${currentLoop}d`].fade(0, 1, 1000);
});

app.ports.removeDramaReq.subscribe(() => {
  if (!currentLoop) return;
  // console.debug("removing drama", currentLoop);
  dramaVolume = 0;
  loadedSounds[`music/${currentLoop}d`].fade(1, 0, 1000);
});

//////////////////
//LOADING ASSETS
//////////////////

// TODO consider specifying only the images needed immediatly to load
var totalAssetsToLoad = 0;
var numAssetsLoaded = 0;
const progressBarEl = document.getElementById("loading-progress");
function assetLoaded(e) {
  // console.log("loaded", e.target.src);
  numAssetsLoaded++;
  progressBarEl.value = numAssetsLoaded / totalAssetsToLoad;
  progressBarEl.innerText = numAssetsLoaded / totalAssetsToLoad;
  if (numAssetsLoaded === totalAssetsToLoad) {
    // console.log("all assets loaded");
    app.ports.assetsLoaded.send(true);
  } else {
    // console.log(`loaded ${numAssetsLoaded} of ${totalAssetsToLoad} assets`);
  }
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
  // console.log("loading image", img.src);
  return img;
}

/////
//audio
/////

const loadedSounds = {};
const audoPrefix = "audio/";
const sounds = {
  "music/1d": { exts: ["mp3", "ogg"], waitForLoad: true },
  "music/1l": { exts: ["mp3", "ogg"], waitForLoad: true },
  "music/2d": { exts: ["mp3", "ogg"] },
  "music/2l": { exts: ["mp3", "ogg"] },
  "music/3d": { exts: ["mp3", "ogg"] },
  "music/3l": { exts: ["mp3", "ogg"] },
  "music/4d": { exts: ["mp3"] },
  "music/4l": { exts: ["mp3"] },
  "sfx/subway_ambient_loop": {
    exts: ["wav"],
    waitForLoad: true,
    loop: true,
    volume: 0.4,
  },
  "sfx/subway_arrival": { exts: ["wav"], volume: 0.7 },
  "sfx/subway_arrival2": { exts: ["wav"] },
  "sfx/subway_departure": { exts: ["wav"], waitForLoad: true },
  "sfx/subway_whistle": { exts: ["wav"], waitForLoad: true, volume: 0.5 },
  "sfx/ambience_crowd_loop": { exts: ["ogg"], loop: true, volume: 0.7 },
};

Object.entries(sounds).forEach(loadSound);

function loadSound([key, { waitForLoad, exts, loop, volume }]) {
  if (waitForLoad) totalAssetsToLoad++;
  let sound = new Howl({
    src: exts.map((ext) => audoPrefix + key + "." + ext),
    loop: loop || false,
    volume: volume || 1,
  });
  if (waitForLoad)
    sound.once("load", assetLoaded.bind(null, { target: { src: key } }));
  // console.log("loading sound", key);
  loadedSounds[key] = sound;
}

////////////////////
//INWORLD
////////////////////

const GENERATE_TOKEN_URL = SERVER_URL + "get_token";
let talkingTo = "";
const startingScene = "workspaces/deadline/scenes/east_mulberry_subway_station";
const charactersPrefix = "workspaces/deadline/characters/";

async function generateSessionToken() {
  // TODO find a way to be more resilient?
  const response = await fetch(GENERATE_TOKEN_URL);
  return response.json();
}

const inworld_client = new InworldClient()
  .setConfiguration({
    capabilities: { audio: false },
  })
  .setUser({ fullName: "Steve" })
  .setScene(startingScene)
  .setGenerateSessionToken(generateSessionToken)
  .setOnError((err) => {
    switch (err.code) {
      // Cancelled by server due timeout inactivity.
      case 10:
      // Cancelled by client.
      case 1:
        break;
      default:
        console.error("inworld error", err);
        break;
    }
  })
  .setOnMessage((msg) => {
    if (msg.isText()) {
      app.ports.promptResponse.send({ id: talkingTo, response: msg.text.text });
    } else if (msg.isInteractionEnd()) {
      // Close connection.
      // inworld.close();
    } else console.debug("Unknown inworld message", msg);
  });
// .setOnReady(() => console.log("Inworld Ready!"))
// .setOnDisconnect(() => console.log("Inworld Disconnect!"));

const inworld = inworld_client.build();
// force it to "preload" a token
inworld.getCurrentCharacter();
window.inworld = inworld;

app.ports.sendPrompt.subscribe(async ([id, prompt]) => {
  if (talkingTo !== id) {
    // console.log("selecting character", id);

    const characters = await inworld.getCharacters();
    const character = characters.find(
      (c) => c.getResourceName() === charactersPrefix + id
    );

    if (character) {
      talkingTo = id;
      inworld.setCurrentCharacter(character);
    } else {
      console.error("could not find character", charactersPrefix + id);
    }
  }
  inworld.sendText(prompt);
});

app.ports.sendTrigger.subscribe(async id => inworld.sendTrigger(id))

////////////////////
//LISTENERS
////////////////////

document.addEventListener("keydown", function (e) {
  if (e.target.tagName != "INPUT") {
    app.ports.keyPress.send(e.key);
  }
  if (e.key == " " || e.key === "Backspace") {
    if (!e.target.tagName in ["INPUT", "TEXTAREA"]) {
      e.preventDefault();
    }
  }
});
