# Features

<div class="alert alert-warning mb-5" role="alert">
  This page is a stub.
</div>

## General purpose

<p class="mb-5">
  Grid is a general purpose 2D multiplayer game engine with first-class support
  for tile-based games. It includes no integrated development environment to
  lock you into the Grid Engine, and allows you to use the tools you prefer
  instead.
</p>

## Pure Lua

<p class="mb-5">
  Grid is a pure Lua game engine. We don't use vendor-specific scripting, such
  as a "GRDScript". If you want to write portable Lua game code, more power
  to you.
</p>

## Powered by LÖVE

<p class="mb-5">
  Grid is built on [LÖVE](https://love2d.org/). If you're familiar with LÖVE,
  it'll be even easier to graduate to game engine features, and you can take
  your LÖVE ecosystem software with you.
</p>

## Client-server architecture

Grid is split into client, server, and shared code. When you're ready to
distribute your game, if you want to hide its server-side implementation,
simply remove the `engine/server/` and `game/server/` directories.

<p class="mb-5">
  Likewise, if you're distributing just the dedicated server, remove the
  `engine/client/` and `game/client/` directories.
</p>

## Engine-game architecture

<p class="mb-5">
  As Grid continues to update, you can sync your fork and pull down changes.
  Engine code is contained in `engine/`, and sample game code in `game/`.
</p>

## Binds
<pre><code>w +forward
s +back
a +left
d +right
lshift +speed
...</code></pre>

Input bindings allow your players to customize their controls and prevent you
from needing to hard-code game commands.

<p class="mb-5">
  <!-- [Learn more about Binds →](tutorials/Binds) -->
  <small>Binds tutorial coming soon.</small>
</p>
