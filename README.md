# termie-plugins

The curated plugin catalog for [termie](https://github.com/lintowe/termie).

`index.json` is fetched by termie's in-app marketplace (command palette → "plugins").
Each plugin ships as a zip of its `plugin.json` plus its entry binary; the installer
downloads the `url`, unpacks it, validates the manifest `id`, and installs it under
`%APPDATA%\termie\plugins\<id>\`.

## Catalog

| id | name | what it shows |
|----|------|---------------|
| `tamagotchi` | Tamagotchi | an animated dock pet you can pet/feed; reacts to focus + bell (Tier-2 graphics demo) |
| `relay` | Session Relay | the inter-plugin bus, logging the `chat` topic |

The security model is trust-the-store: a plugin runs as a separate process (crash-isolated, not sandboxed), so only vetted plugins belong here.
