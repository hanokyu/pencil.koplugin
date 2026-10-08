# pencil.koplugin (Kobo Elipsa 2E fork)

This is a personal fork of [mysticknits/pencil.koplugin](https://github.com/mysticknits/pencil.koplugin), used to test the plugin on my own **Kobo Elipsa 2E** with the **Kobo Stylus 2**.

All changes in this fork were vibe-coded with [Claude](https://claude.com/claude-code): I describe what I see on the device, Claude reads the code, writes the fix and tests, and I try it on the Elipsa 2E. Expect rough edges. It is only tested on that one device, so for other Kobo models use the [original plugin](https://github.com/mysticknits/pencil.koplugin) instead.

All credit for the plugin itself goes to **[mysticknits](https://github.com/mysticknits)** and the contributors listed in [Credits](#credits).

### What's different from upstream

- Holding the side button to highlight text no longer switches the tool to the eraser or shows a "Tool: eraser" message.
- Quick dots (`...`, the dots on i and j) are no longer dropped, and strokes start exactly where the pen lands.
- The end of a stroke shows up as soon as the pen lifts, instead of appearing late.
- Lower writing latency: fast refresh for dark ink, and a save debounce that actually works.
- The eraser end keeps up with the pen, even in books with many strokes and highlights.
- Pulled in from open upstream pull requests: no crash from pencil bookmarks at invalid positions ([#89](https://github.com/mysticknits/pencil.koplugin/pull/89)), strokes follow a renamed book ([#86](https://github.com/mysticknits/pencil.koplugin/pull/86)), and a smaller, faster save format ([#77](https://github.com/mysticknits/pencil.koplugin/pull/77)).

Back up your books' `.sdr` folders before switching to this fork. Strokes saved by it can't be read by older versions of the plugin.

### Install with Storefront

With [Storefront](https://github.com/ultimatejimmy/storefront.koplugin): refresh the catalog, search for **pencil**, open **hanokyu/pencil.koplugin** and choose **Install from branch… → main**. Storefront then shows an update whenever `main` changes. Don't apply an update to the upstream pencil entry, as it would replace this fork.

You still need the patched `input.lua` from this repo (see [Instructions for Installation](#instructions-for-installation)).

## Information

The upstream plugin has been tested on:

- Kobo Libra Colour/Kobo Stylus 2/Epub format

This fork is tested on:

- Kobo Elipsa 2E/Kobo Stylus 2/Epub format

**This will currently only work on Kobo devices!**

If you resize your book while reading it, your annotations will be WONKY. Get your book set before you start writing.

### Compatible with Koreader - Snowflake

## Features

- **Pen tip**: Draw annotations on your ebooks
- **Eraser end**: Flip your stylus over to erase strokes instantly
- **Highlighter**: Hold the stylus side button and drag to highlight; tap the side button to toggle pencil/eraser
- **Swap Eraser/Highlighter**: Reassign which side button acts as eraser vs. highlighter from the menu
- **Undo**: Undo your last stroke or eraser action
- **Clear strokes**: Clear annotations for the current page or the entire document
- **Annotation grouping**: Strokes are automatically grouped into logical annotations based on timing and proximity
- **Enable/disable toggle**: Turn the plugin on or off via the menu or a mapped gesture
- **Per-document storage**: Annotations are saved with each book
- **Input debug mode**: Log raw stylus events to help diagnose detection issues

## Instructions for Installation

1. Download both the `pencil.koplugin` directory and the `input.lua` file from this repository.
2. Replace the `/frontend/device/input.lua` with the downloaded file. This enables the plugin to intercept the stylus input, separate it from touch inputs, and detect the eraser end.
3. Copy the `pencil.koplugin` directory into the `/plugins` directory of KOReader.

## Configuring the Pencil Plugin

1. Enable the plugin from the Pencil menu (Top menu > More tools > Pencil > Enabled)
2. If your stylus's side button mapping is reversed, toggle **Swap Eraser and Highlighter** in the Pencil menu
3. Optionally map actions to gestures in Gesture Manager:
   - **Pencil: toggle on/off** — enable or disable the plugin
   - **Pencil: toggle pencil/eraser** — switch between tools
   - **Pencil: select pencil** — switch to pencil
   - **Pencil: select eraser** — switch to eraser
   - **Pencil: undo** — undo last stroke or eraser action

## Questions or Issues with the Plugin

This fork is a personal test build and does not take issue reports. If a problem also happens with the original plugin, please report it to [mysticknits/pencil.koplugin](https://github.com/mysticknits/pencil.koplugin/issues).
If you're experiencing issues with the plugin, please enable input debug mode in the Pencil menu, reproduce the issue, and include the debug log file in your report.

## Experimental Features

Some features are still in development and are hidden behind an experimental toggle. You can find them under **Pencil menu > Experimental**.

### Color picker

When enabled, holding the pen still on the page opens a picker with 10 color options. When disabled, the pen stays on its last-saved color.

**To enable:** Pencil menu > Experimental > Color picker

### Pen width picker

When enabled, the picker also shows pen width options (3, 5, 7, 9), rendered as black bars whose height previews the stroke thickness. **Requires the color picker to also be enabled.**

**To enable:** Pencil menu > Experimental > Pen width picker

### Bookmark Sync

When enabled, the plugin automatically groups your pencil strokes into logical annotations (based on timing and proximity) and creates KOReader bookmarks for each one. This means annotated pages show up in the **Bookmarks menu**, so you can quickly navigate back to pages you've written on.

**To enable:** Pencil menu > Experimental > Bookmark sync

**What happens when you turn it on:**
- Existing pencil annotations are grouped and bookmarks are created immediately
- New strokes are grouped and bookmarked as you draw
- Bookmarks appear in KOReader's Bookmarks menu as "Pencil annotation on page X"
- Erasing or undoing strokes updates the bookmarks automatically

**What happens when you turn it off:**
- All pencil bookmarks are removed from the Bookmarks menu
- Your pencil strokes and drawings are not affected — only the bookmarks are removed
- Annotation groups are still tracked internally, so you won't lose any grouping data if you turn it back on

## Features In the Pipeline

1. Export of annotations
2. Handling changing canvas size

## Credits

- **[mysticknits](https://github.com/mysticknits)**: author of pencil.koplugin. Nearly everything in this fork is their work.
- Contributors to the original plugin:
  - [janoschp](https://github.com/janoschp): colorful strokes
  - [Euphoriyy](https://github.com/Euphoriyy): night mode colors
  - [CharlieQLe](https://github.com/CharlieQLe): side button detection
  - [AndyHazz](https://github.com/AndyHazz): stylus input with invisible overlays
- Authors of the upstream pull requests merged into this fork:
  - [andrew-lawlor](https://github.com/andrew-lawlor): bookmarks at invalid positions ([#89](https://github.com/mysticknits/pencil.koplugin/pull/89))
  - [bateast](https://github.com/bateast): strokes follow a renamed file ([#86](https://github.com/mysticknits/pencil.koplugin/pull/86))
  - laurenamy: v4 save format (from [#77](https://github.com/mysticknits/pencil.koplugin/pull/77))
- Eraser end detection is based on techniques from [eraser.koplugin](https://github.com/SimonLiu423/eraser.koplugin) by SimonLiu.
- Fork changes written with [Claude Code](https://claude.com/claude-code).

Licensed under the same license as the original plugin (see [LICENSE](LICENSE)).
