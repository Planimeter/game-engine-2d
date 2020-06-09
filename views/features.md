# Features

<div class="alert alert-warning mb-5" role="alert">
  This page is a stub.
</div>

<div class="row">
  <div class="col-6">
    <h2>
      General purpose
    </h2>

    <p class="mb-5">
      Grid is a general purpose 2D multiplayer game engine with first-class
      support for tile-based games. It includes no integrated development
      environment to lock you into the Grid Engine, and allows you to use the
      tools you prefer instead.
    </p>
  </div>

  <div class="col-6">
    <h2>
      Pure Lua
    </h2>

    <p class="mb-5">
      Grid is a pure Lua game engine. We don't use vendor-specific scripting,
      such as a "GRDScript". If you want to write portable Lua game code, more
      power to you.
    </p>
  </div>

  <div class="col-6">
    <h2>
      Powered by LÖVE
    </h2>

    <p class="mb-5">
      Grid is built on [LÖVE](https://love2d.org/). If you're familiar with
      LÖVE, it'll be even easier to graduate to game engine features, and you
      can take your LÖVE ecosystem software with you.
    </p>
  </div>

  <div class="col-6">
    <h2>
      Engine-game architecture
    </h2>

    <p class="mb-5">
      As Grid continues to update, you can sync your fork and pull down
      changes. Engine code is contained in `engine/`, and sample game code in
      `game/`.
    </p>
  </div>

  <div class="col-6">
    <h2>
      Client-server architecture
    </h2>

    <p>
      Grid is split into client, server, and shared code. When you're ready to
      distribute your game, if you want to hide its server-side implementation,
      simply remove the `engine/server/` and `game/server/` directories.
    </p>

    <p class="mb-5">
      Likewise, if you're distributing just the dedicated server, remove the
      `engine/client/` and `game/client/` directories.
    </p>
  </div>

  <div class="col-6">
    <h2>
      Binds
    </h2>
    <pre><code>w +forward
s +back
a +left
d +right
lshift +speed
...</code></pre>

    <p>
      Input bindings allow your players to customize their controls and prevent
      you from needing to hard-code game commands.
    </p>

    <p class="mb-5">
      <!-- [Learn more about Binds →](tutorials/Binds) -->
      <small>Binds tutorial coming soon.</small>
    </p>
  </div>

  <div class="col-6">
    <h2>
      W3C box model-based graphical user interfaces
    </h2>

    <p>
      Grid comes with generic reference implementations of default user
      interfaces for common game engine functionality. The UI can be used
      either out of the box or replaced with your own customized views.
    </p>

    <p>
      The engine provides familiar UI building techniques, industry standard
      layout algorithms, stylesheets, and advanced panel compositing features
      like transluency and transform animations.
    </p>

    <p class="mb-5">
      <!-- [Learn more about GUIs →](tutorials/GUIs) -->
      <small>GUI tutorial coming soon.</small>
    </p>
  </div>

  <div class="col-6">
    <h2>
      In-engine console
    </h2>

    <p>
      Run console commands and set console variables from within Grid's
      in-engine console.
    </p>

    <p class="mb-5">
      <!-- [Learn more about the Console →](tutorials/Console) -->
      <small>Console tutorial coming soon.</small>
    </p>
  </div>

  <div class="col-6">
    <h2>
      Options menu
    </h2>

    <p>
      Set input binds, configure your video and sound from Grid's out of the
      box options menu.
    </p>
  </div>
</div>
