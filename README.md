[![image](https://img.itch.zone/aW1nLzQ5OTkwOTcuanBn/original/wFBD9F.jpg)](https://enegames.itch.io/deadline)

# Welcome to the subway...

A narrative adventure game following an unappreciated insurance agent who falls into a subterranean labyrinth when his subway commute goes awry.

## [Play now](https://enegames.itch.io/deadline)

![](https://img.itch.zone/aW1hZ2UvODg2NTYwLzQ5OTgzMDUuanBn/794x1000/WMb%2Fm%2B.jpg)
![](https://img.itch.zone/aW1hZ2UvODg2NTYwLzQ5OTgzMDEuanBn/794x1000/PIQT%2BM.jpg)
![](https://img.itch.zone/aW1hZ2UvODg2NTYwLzQ5OTgyOTguanBn/794x1000/MvdIuR.jpg)


---

Build on the Elm Narrative Engine

# Interactive Story Starter

A starting point to build your own interactive stories using the [Elm Narrative Engine](http://package.elm-lang.org/packages/jschomay/elm-narrative-engine/latest).

The Elm Narrative Engine is a unique tool for telling interactive stories. It features a context-aware rule-matching system to drive the story forward, and offers a total separation of logic, presentation, and content, making it an extremely flexible and extensible engine. 

You can read the [full API and documentation](http://package.elm-lang.org/packages/jschomay/elm-narrative-engine/latest), follow along with [developement](http://blog.elmnarrativeengine.com/), and play some [sample stories](http://blog.elmnarrativeengine.com/sample-stories/).


## Getting started

This repo contains a fully featured sample story that you can clone and extend for your own use.  The Elm Narrative Engine is written in [Elm](http://elm-lang.org), and so is this client code.

Run this code with `npm i` (to install) and then `npm start` (to serve it).  Then you can open your browser window to http://localhost:8080/ to see the story.  `npm run build` will build the code into the `/dist` directory.

Here is the [demo](http://blog.elmnarrativeengine.com/sample-stories/little-red-riding-hood/classic/) of what this story starter creates.

The simplest way to start writing your own story is to modify the `Manifest.elm`, `Rules.elm` and `Narrative.elm` files with your own content.  You can also change the theme by changing the code in the `Theme` directory.  All of these source files live under the `/src` directory.


## More advanced

This code uses a pattern called the Entity Component System pattern, which allows for strong decoupling.  You don't have to use this pattern, but I find it very helpful.

In a nutshell, each "object" in your story is an "entity," which has an id.

"Components" can be anything that adds more meaning or content to an entity, such as a description, or an image file.  You can add components as you need them by defining what data types the component uses, then associating that component and its specific data with an entity id.

Each component has a "system," which does something meaningful with the component data, such as rendering the description or image.

You will find some component data being added to various entities in the `Manifest.elm` file, which gets "plucked" out for use in the theme and `Main.elm` files.  The source files are annotated with comments, explaining the specifics further.

Enjoy creating your interactive story!
