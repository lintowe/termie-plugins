# termie-plugins

The plugin registry for [termie](https://github.com/lintowe/termie) — the source
for every plugin plus the catalog its in-app store reads.

`index.json` (repo root) is fetched by termie's marketplace (command palette →
"plugins"); each entry's `url` points at a `dist/<id>-<version>.zip` of that
plugin's `plugin.json` + entry binary. The installer downloads the zip, validates
the manifest `id`, and installs under `%APPDATA%\termie\plugins\<id>\`.

## Catalog

| id | name | what it does |
|----|------|--------------|
| `tamagotchi` | Tamagotchi | an animated dock pet you can pet/feed; reacts to focus + bell (Tier-2 graphics demo) |
| `relay` | Session Relay | the inter-plugin message bus, logging the `chat` topic |

## Layout

```
termie-plugins/
├── index.json              catalog the app fetches
├── <id>/                   one folder per plugin: plugin.json + source
├── scripts/build-zips.ps1  builds + packs dist/<id>-<version>.zip, regenerates index.json
└── dist/                   generated zips (tracked; served via raw.githubusercontent)
```

Plugins are kept self-contained per folder (not a single Cargo workspace) so a
plugin can be written in any language, not just Rust.

## Building + publishing

```powershell
pwsh scripts/build-zips.ps1   # builds every plugin, refreshes dist/ + index.json
```

Then commit the updated `index.json` + `dist/*.zip` and push. termie's store reads
`index.json` straight from `main`, so a push publishes.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Note the trust model: plugins run as native
processes with the user's rights, so the registry is review-gated — every plugin
ships from reviewed source here.

## License

MIT — see [LICENSE](LICENSE).
