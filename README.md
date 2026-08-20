# dsh-plugins

[DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) (DSH) plugins maintained by InstruktAI.

Every plugin directory is a self-contained Cordis package with its own README — start there.

## Plugins

| Plugin | Version | What it does |
| --- | --- | --- |
| [**dsh-hooks**](dsh-hooks/README.md) | 0.3.2 | Claude Code style lifecycle hooks — run shell or HTTP hooks on agent and tool events, configured from `.dsh/hooks.json`. |

## Installing

`./install.sh` links this checkout into `$DSH_HOME` and installs every plugin into every existing profile. It is idempotent — rerun it after pulling.

```sh
./install.sh
```

To install one plugin by hand, `dsh plugin add` forwards verbatim to pnpm, so any pnpm source works — including a single directory of this monorepo, via pnpm's `path:` parameter:

```sh
dsh plugin --profile <profile> add "github:InstruktAI/dsh-plugins#main&path:/<plugin>"
```

- **Quote the whole spec.** The `&` separates the git ref from the `path:` parameter; unquoted, the shell backgrounds the command.
- Pin a commit or tag for reproducible installs: `#<commit-or-tag>&path:/<plugin>`.
- After a successful install the profile's bundle list is reconciled from the installed packages, so any plugin declaring `dsh.bundle` joins the layer stack — git-ref installs behave exactly like npm or tarball installs.
- New sessions pick a plugin up automatically. Existing sessions must be recreated: wiring happens on `agent/created` and a session's tool catalog is pinned at session start.

Per-plugin install options and prerequisites are in each plugin's README.

## Layout

```
dsh-plugins/
├── dsh-hooks/                            # lifecycle hooks
├── dsh_install_plugins_all_profiles.sh   # installs the plugins into every profile
├── install.sh                            # links the checkout into $DSH_HOME, then installs
├── AGENTS.md                             # working agreements for this repository
└── LICENSE
```

## Development

Packages here are `private`: distribution is this repository, not npm. Install a working copy into a profile with a `file:` ref and recreate the session to pick it up.

```sh
cd dsh-hooks && npm test    # node --test test/*.test.mjs
```

Verification for each plugin is described in its own README; the primary path is the live runtime, not unit tests.

## License

MIT — see [LICENSE](LICENSE).
