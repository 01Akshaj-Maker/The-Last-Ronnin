# The Last Ronin — Project Bible

> Master brief and context for the whole project. Level of intent and principle, not a
> technical blueprint — where the how isn't stated, use judgment and keep things modular.
> If something here conflicts with an ad-hoc instruction, ask before diverging.

## 1. Pitch

A legendary samurai wakes after a great war. His lord is dead, his clan is gone, his sword is
cracked. He's given one final mission: *travel across the land and deliver a final message.* He
doesn't know who gave it or why. Along the way he meets villagers, monks, thieves, children,
and old enemies, and at every turn chooses how to act. At the destination there's no one — only
his own grave. He died in the war years ago. The journey was never about a message. It was about
deciding what kind of person he had been before moving on.

**Theme: MEMENTO MORI** — *remember that you must die.* The spine of the story, not decoration.
It must be felt, not stated.

## 2. The One Rule That Governs Everything

**Choices affect reflection and framing, NOT the plot.** The samurai always visits the same
chapters in the same order and always reaches the same grave. Choices change only: who he turns
out to have been, how the world reflects that back at him, and how the final grave scene looks and
reads. Never branch the plot or fork the chapter order. If a feature would require branching the
story, branch *reflection* instead.

## 3. How Choice Works (the load-bearing system — build early)

Four hidden counters track dimensions of character, starting at 0, moving up/down as the player
acts. The player never sees numbers, only consequences. Suggested axes (refine names/tuning
yourself): **Honor**, **Mercy**, **Attachment** (clinging vs. letting go), **Selflessness**.

Three layers turn counters into meaning:

- **Accumulated identity** — counters silently sum across the whole game.
- **Reflected world** — later scenes read the counters and change their *framing*. Spare a thief
  early → a beggar later mentions a reformed thief who helped him; kill him → a body was found in a
  ditch. Same scene slot, conditional content. Highest impact for lowest cost — use liberally.
- **Ending state** — the grave scene assembles from the counters: the epitaph text and the scene's
  *visual mood* (blossoms and warm light for mercy/letting-go; snow, bare branches, grey sky for
  vengeance/attachment). One ending, swapped mood.

Optionally seed 3–5 clearly weighty choices that move the counters more than small ones. Keep this
system easy to extend — adding a choice should be trivial.

## 4. Gameplay

Top-down 2D pixel art. **Core loop, in build priority:** walk a small handcrafted area → talk to
an NPC → choose (adjusts counters) → the world reflects past choices → arrive at the grave (ending
assembles from who you became). Everything else layers on top and is cut first if time is short.

**Secondary (nice-to-have):** light combat — secondary, off the critical path, forgiving or
skippable so a rough fight never blocks the ending; small puzzles for pacing; exploration of small
dense areas, not open world; bosses reserved for one or two chapters at most (most chapters climax
on a narrative or puzzle beat).

**Chapters:** small, self-contained, distinct-mood areas (rainy village, bamboo forest, snow
mountain, temple, cherry-blossom fields). Self-contained so any one can be cut and the game still
ships. Each: arrive → explore → meet people → choose → climax → move on.

**The twist (never spoiled until the end):** the destination holds only his own grave; he died in
the war. Seed subtle hints throughout (people react oddly, things he shouldn't remember, a wound
that never heals) so the reveal feels earned in hindsight.

## 5. Build Order (always keep something submittable)

1. **Core loop skeleton** — walk, talk, 2-choice dialogue, one area. Grey boxes are fine.
2. **Identity system** — the four counters, choices that move them, a placeholder ending that reads
   them out. This is the theme; get it working early.
3. **One gorgeous complete chapter** (vertical slice, e.g. the rainy village) — real art, dialogue,
   2–3 meaningful choices, a small puzzle, atmosphere, audio.
4. **Ending scene** — epitaph assembly + visual mood state. Now it's complete end-to-end.
   **This is the minimum viable submission.**
5. **More chapters** — mostly content, reusing existing systems. Add as time allows.
6. **Polish** — game feel, transitions, audio, Developer Diary.

If you must cut, cut from the bottom. Never sacrifice steps 1–4.

## 6. Visual & Audio Direction

Pixel art, painterly and moody; small polished areas over large empty ones. Motifs: cherry
blossoms, bamboo, temples, rainy villages, snow mountains — weather and light carry emotion. The
ending's visual mood (blossoms/warm vs. snow/grey) is a gameplay output, so build areas so their
mood can shift. Audio sparse and atmospheric — silence and ambience (rain, wind, a distant bell) do
heavy lifting; music at key beats only.

## 7. Asset Manifest (target list)

External assets are allowed only if they aren't the primary creative work and each is declared with
source + license (see §8). Aim to cover:

- **Characters** — Samurai (idle, walk, attack, hurt, death); 3–5 NPCs (villager, monk, merchant,
  child, guard); 2–3 enemies (bandit, rogue samurai, wolf); 1 boss (elite samurai or demon).
- **Environment** — grass/dirt/stone/water tiles, trees, bushes, rocks, bamboo, cherry blossom
  trees, flowers, cliffs. **Buildings** — house exterior & interior, temple, torii gate, small
  bridge, shrine, castle entrance. **Props** — barrels, crates, campfire, lanterns, wooden fences,
  signboards, wells, benches, market stalls, wagons. **Weapons** — katana, broken katana (story),
  enemy spear, optional bow. **Collectibles** — coins, scrolls, letters, charms, herbs, memory
  fragments (story items). **Effects** — sword slash, dust, blowing leaves, rain, snow, minimal
  blood (optional), sparks, fire. **Audio** — calm Japanese-style BGM, battle music, boss music,
  wind ambience, birds, water stream, footsteps, sword swing, hit sounds, NPC dialogue blips.
  **UI** — main menu, health bar, dialogue box, inventory, pause menu, settings, optional quest
  log. **Story art** — intro screen, ending artwork, optional character portraits.

Treat this as a coverage checklist, not a rigid order — prioritize whatever the current build step
(§5) needs. Memory fragments and the broken katana are story-critical; don't treat them as generic
props.

## 8. Maintaining `ATTRIBUTIONS.md`

Every external/stock asset — art, audio, fonts, shaders, code snippets — must be logged in a single
`ATTRIBUTIONS.md` at the project root. Treat this file as part of the build, not paperwork for later.

- **Create it on day one**, the first time any external asset enters the project. It exists before
  the first sprite is imported, not after.
- **Log every asset with four things:** asset name, author/creator, source URL, and the real license
  (MIT / CC0 / CC-BY / CC-BY-SA / etc.). If the license requires attribution text or a specific
  notice, copy that exact wording in.
- **Update it in the same step the asset changes** — added, swapped, or removed. Never batch
  attributions "for later." An un-attributed asset in the project is a bug, and should be fixed like
  one.
- **Verify the real license before using anything.** "Found on GitHub" is not a license. Much pixel
  art and audio is attribution-required, non-commercial, or share-alike — confirm each pack's actual
  terms before it goes in.
- **Keep original work as the heart.** External sprites and sounds serve our creation — the writing,
  the identity system, the level design, the systems, and the integration are ours. Anything
  external is a supporting asset, never the primary creative work.
- **Keep this bible and `ATTRIBUTIONS.md` in sync** as the game grows; don't let either drift.

## 9. Building Principles (you decide the technical how)

- **Keep everything modular and loosely connected** — changing or adding one thing shouldn't ripple
  through the rest. New chapters, NPCs, choices, and mechanics should be easy, localized additions.
- **Keep the file structure future-proof** — new content slots in without restructuring; one
  responsibility per file; many small files over few big ones; split a file when it does two jobs.
  Before adding something, check the structure absorbs it cleanly — tidy first if not.
- **Content as data, not code** — dialogue, choices, chapters, NPCs, and choice effects should be
  editable content, so authoring new content isn't rewriting systems.
- **Clear ownership:** logic and systems are AI-built; hand-placed art, level layout, and game feel
  are the human team's.
- **Keep it changeable** — favor easily reversible/extendable decisions over clever locked-in ones.

## 10. Working Agreements

- Small, verifiable increments: build one thing → run it → describe the exact error or wrong
  behavior → fix. Not the whole game at once.
- Commit after every working increment — it's both a safety net and honest raw material for the
  Developer Diary.
- Game feel is a human job — the team plays and describes what's off.
- Keep this brief and `ATTRIBUTIONS.md` in sync as the game grows; don't batch either for "later."

---

*Interpret freely where unspecified. Stay modular. Protect the core loop and the identity system
above all else. The grave the player reaches should be theirs in more ways than one.*
