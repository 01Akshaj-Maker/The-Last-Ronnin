# Attributions

All external/stock assets — art, audio, fonts, shaders, code snippets — are logged here per §8 of
the [Project Bible](PROJECT_BIBLE.md). Every entry records: **asset name**, **author/creator**,
**source URL**, and the **real, verified license** (with any required attribution wording copied in
verbatim).

## Samurai 2D Pixel Art (v1.2) — player character sprites
- **Author/creator:** xzany
- **Source:** https://xzany.itch.io/samurai-2d-pixel-art
- **Used for:** the Player character animations (idle, run, attack, hurt). Sheets copied to
  `assets/characters/samurai/` (idle/run/attack/hurt.png), 96×96 frames, horizontal strips.
- **License:** Free for use in any game project, personal or commercial. Credit not required
  (but appreciated). May be modified. Must be part of a project — not resold or redistributed as a
  standalone game asset. Not to be turned into an NFT. Full text preserved at
  `assets/characters/samurai/LICENSE.txt`. Verbatim:
  > You can use this asset in any game project, personal or commercial.
  > DO NOT resell or redistribute AS A GAME ASSET, it has to be part of a project.
  > Credit is not required but it is appreciated.
  > Modify to suit your needs.
  > You are NOT allowed to turn any of my assets to an NFT.

## Tiny Pixel Japan Male Character Pack — NPC sprites
- **Author/creator:** Lynia Design (lyniadesign)
- **Source:** https://lyniadesign.itch.io/tiny-pixel-japan-male-character-pack
- **Used for:** village NPC characters. Sheets copied to `assets/characters/npc/`
  (ronin/samurai/lord/villager.png; 29×28 frames, two colour variants each, side-view idle).
  The **Thief** uses the Ronin, the **Child** uses the young Villager (scaled down).
- **Modification:** `assets/characters/npc/widow.png` is a recolour of the pack's old-villager
  variant (olive robe → indigo, hair lightened) to stand in for the **Widow**, since the pack
  has no female sprite. Derived from this pack; same license applies.
- **License:** Confirmed by the project owner: free for commercial use. (itch.io pack; no
  license file shipped in the folder — usage rights confirmed directly by the owner.)

## Feudal-Japan Tileset & Prop Pack (war-torn / snow / green sets) — SUPERSEDED, no longer shipped
- **Author/creator:** not recorded — the pack name and author were never supplied by the project
  owner, and the pack was retired before that gap was closed (see status below).
- **Source:** not recorded (private hand-off; no itch.io/marketplace URL was provided).
- **Status:** **Superseded during the v2 art pass and removed from active use.** This was the first
  environment-art pass: its six sheets were extracted into per-biome folders under
  `assets/environment/` (`warvillage/`, and the original ground/prop seeds of `bamboo/` and
  `snow/`). Judged too low-quality, it was replaced everywhere by the ForgottenMemories pack below.
  The extracted sheets and their old `*_tileset.tres` still sit on disk but are **not referenced by
  any scene or TileSet** — no pixel from this pack appears in the current build.
- **Used for (historical):** the first tileset pass of the walkable chapters — war-torn village
  buildings/torii/wells/fences, a green bamboo set, and a snow set (drifts, rocks, snow torii,
  gravestones, banners). All since replaced.
- **License:** Confirmed verbally by the project owner as licensed for use in this project. Because
  the pack no longer ships, no attribution obligation carries into the released game; the retained
  provenance here is historical. If the extracted folders are ever revived, the exact terms and
  author/source must be captured first (Bible §8).

## ForgottenMemories (fm32x32) — terrain + nature for every walkable chapter (v2 art pass)
- **Author/creator:** immunitys
- **Source:** https://immunitys.itch.io/fm32x32
- **Used for:** the redesigned terrain of all four walkable chapters, all driven by the same 32px
  neighbour-selected autotiler (a real grass↔path road with tufted transitions):
  - **Village** — grass/dirt floor + trees/bushes/stumps/rocks + rock-rimmed pits (ruined
    foundations). Painter `scripts/world/village_ground.gd`.
  - **Bamboo Forest** — the same grass/dirt floor (layer-modulated cooler/greener) with FM
    willows/pines/bushes/rocks for depth. Painter `scripts/world/bamboo_ground.gd`.
  - **Snow Mountain** & **Final Approach** — a **winter recolour** of the FM tileset (green→snow,
    dirt→packed trodden path), so its real transition tiles paint snow↔trail. Painters
    `scripts/world/snow_ground.gd`, `final_ground.gd`.
  Sheets copied to `assets/environment/fm/` (`tileset.png`, `props.png`, `trees.png`); cut-out
  props in `fm/props/`; TileSet `fm/fm_tileset.tres`.
- **Modification:** `assets/environment/snow/snow_tileset.png` is a hue-classified luminance recolour
  of `fm/tileset.png` (shading structure preserved, no tiles repainted). Derived work; same license.
- **License:** "Name your own price" itch.io pack (free download available). Free for personal and
  commercial use; may be edited; credit not required (but appreciated); may NOT be repackaged,
  redistributed, or resold. Verbatim, from the pack page:
  > Assets can be edited and used for personal and commercial use. Credit is not necessary but it is
  > highly appreciated. You may not repackage, redistribute or resell the assets, modified or not.

  Our use complies: the pack drives the shipped game and its derived snow recolour, and neither the
  originals nor the recolour are redistributed as a standalone asset.

## Original generated props (this project) — bamboo / winter / grave art
- **Author/creator:** made for The Last Ronin (procedural pixel-art, PIL).
- **Used for:** the signature pieces the packs above don't cover, generated as clean 32-px-style
  pixel art and base-anchored like the pack props: bamboo culm clumps, a vermilion **torii**, stone
  lantern, jizō, stele, temple bell, kabuto, ferns/reeds (`assets/environment/bamboo/props/`);
  snow-laden pines, snow-capped rocks/spire, drifts, a cairn, a snow-dusted torii, a war banner, a
  snow-buried fallen warrior, and the final grave monument (`assets/environment/snow/props/`); plus
  the village gate & signpost (`fm/props/`).
- **License:** original work; no third-party rights.

## Pixel Crawler — Free Pack (anokolisa, 16×16) — available, not yet used
- **Author/creator:** Anokolisa
- **Source:** https://anokolisa.itch.io/free-pixel-art-asset-pack-topdown-tileset-rpg-16x16-sprites
- **License (from bundled Terms.txt):** free to use in commercial/study/any projects; may be
  altered; credit appreciated but not required; may NOT be resold/redistributed as an asset.
- **Used for:** nothing yet (fantasy interior/dungeon/building kit; held for possible later use).

## pixel_16_woods v2 (zedpxl, 16×16) — available, not used
- **Author/creator:** zedpxl
- **Source:** https://zedpxl.itch.io/pixelart-forest-asset-pack
- **Used for:** nothing — the Bamboo Forest was built from the FM pack + generated bamboo instead,
  to keep one consistent 32px look across chapters. Held for possible later use.
- **License:** free and paid versions available; both permit commercial and non-commercial use, and
  modification; may NOT be resold or redistributed (even if modified); may NOT be used for AI- or
  NFT-related purposes. Verbatim, from the pack page:
  > This asset pack(free and paid) can be used in commercial and non-commercial projects. You can
  > modify it for your needs, but you cannot resell or redistribute it, even if modified. You cannot
  > use this asset pack for AI or NFT related things.

<!--
Entry template — copy per asset:

## <Asset name>
- **Author/creator:** <name>
- **Source:** <URL>
- **License:** <MIT / CC0 / CC-BY 4.0 / CC-BY-SA 4.0 / ...>
- **Required notice:** <exact attribution text if the license requires it, else "none">
-->
