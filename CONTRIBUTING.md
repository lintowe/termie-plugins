# Contributing a plugin

termie plugins are **separate processes** that termie launches and talks to over
newline-delimited JSON on stdin/stdout, so a plugin can be written in any
language. It renders widgets in termie's side dock and reacts to host events. The
protocol is documented in termie's
[`docs/plugin-system-plan.md`](https://github.com/lintowe/termie/blob/main/docs/plugin-system-plan.md);
the reference plugins here (`tamagotchi`, `relay`) are worked examples.

## Trust model — read this first

A plugin runs as a **native process with the user's full rights** — crash-isolated,
but not sandboxed unless the user opts into the AppContainer sandbox. This registry
is therefore **review-gated**: every plugin is published from source in this repo,
and a maintainer reads that source before it ships. Submit only code you would run
on your own machine; don't submit opaque prebuilt binaries.

## Repo layout

```
termie-plugins/
├── index.json              the catalog termie's in-app store fetches
├── <id>/
│   ├── plugin.json         manifest (shipped in the zip)
│   ├── main.rs / src/      the plugin source
│   ├── Cargo.toml          build manifest (rust plugins)
│   └── README.md           what it does
├── scripts/build-zips.ps1  builds every plugin, packs dist/<id>-<version>.zip, regenerates index.json
└── dist/                   generated zips (tracked; served via raw.githubusercontent)
```

## Manifest (`plugin.json`)

```json
{
  "id": "my-plugin",
  "name": "My Plugin",
  "version": "0.1.0",
  "api_version": 2,
  "description": "one line shown in the store",
  "entry": { "cmd": "my-plugin.exe", "args": [] },
  "permissions": []
}
```

- `id` — unique, lowercase, matches the folder name.
- `entry.cmd` — the built binary; it sits beside `plugin.json` in the zip.
- `permissions` — sensitive ones (`read_output`, `write_pty`) stay off unless the
  user grants them at install.

## Submitting

1. Fork this repo and add an `<id>/` folder with your source + `plugin.json`.
2. Build and pack: `pwsh scripts/build-zips.ps1` (regenerates `index.json` and
   `dist/<id>-<version>.zip`).
3. Commit your source, the new `dist/*.zip`, and the updated `index.json`.
4. Open a pull request describing what the plugin does and why it needs any
   permission it requests.

A maintainer reviews the source, rebuilds to confirm the zip matches, and merges.
The plugin then shows up in termie's in-app store (command palette → "plugins").
