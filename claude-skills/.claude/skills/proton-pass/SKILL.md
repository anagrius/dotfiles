---
name: proton-pass
description: Read and manage items in the user's Proton Pass vaults via the `pass-cli` CLI. Use this skill whenever the user asks to look up a password, find a credential, retrieve a key from Proton Pass, store something in their password manager, or interact with `pass-cli` from the terminal. Triggers include "pass-cli", "Proton Pass", "look up my X password", "find the key for Y", "trash this Pass item", "what's in my Personal/Turbotrace vault".
---

# Proton Pass (pass-cli) Skill

`pass-cli` is the official Proton Pass command-line client. Binary at `~/.local/bin/pass-cli`. It mirrors the structure of the desktop/web app — items live inside vaults, items have a typed content body, and arbitrary "extra fields" can be attached.

## Vaults

The user has two vaults:

- **Personal** — personal items
- **Turbotrace** — work items. Note: "Turbotrace" is the legacy name for the company; the user now refers to the company as **Berserk**. When the user mentions Berserk-related credentials, look in `Turbotrace`.

There is no default vault unless explicitly set, so most commands require a vault hint (`--vault-name`, `--share-id`, or a positional argument depending on the subcommand).

## Authentication

```bash
pass-cli info          # check whether a session is active and which user
pass-cli login         # browser-based login, then prompts for an extra password
pass-cli logout
pass-cli test          # verify the API connection works
```

**Important:** the user has the Proton Pass "Extra Password" feature enabled. After the browser OAuth step, `pass-cli login` prompts for a second password that decrypts the vaults. You **cannot automate this** — if `pass-cli` returns an auth error, ask the user to run `! pass-cli login` themselves.

If a command needs a session and one isn't active, you'll see errors like `Error: not authenticated`. Run `pass-cli info` first when in doubt.

## Listing items

```bash
# Vault names and share IDs
pass-cli vault list

# Items in a specific vault (vault name is POSITIONAL here, not a flag)
pass-cli item list Personal
pass-cli item list Turbotrace

# Each line: - [<item_id>]: <title> (state=<Active|Trashed>)
```

The IDs are long base64 strings ending in `==`. Same title can appear multiple times — typically one `Active` and one `Trashed` copy. Always check the `state=` suffix when picking an ID.

To filter, just pipe through `grep`:

```bash
pass-cli item list Personal 2>/dev/null | grep -iE 'gpg|ssh|aws'
```

## Viewing an item

```bash
pass-cli item view --vault-name Personal --item-title "thomas@bzrk.dev GPG"
pass-cli item view --vault-name Personal --item-id '<base64-id>=='
pass-cli item view --vault-name Personal --item-id '<id>' --field <field>
pass-cli item view --vault-name Personal --item-id '<id>' --output json
```

Useful flags:
- `--vault-name <NAME>` — required when not using `--share-id`
- `--item-id <ID>` — exact item; required when titles collide (e.g. active + trashed)
- `--item-title <TITLE>` — convenient when titles are unique
- `--field <NAME>` — extract a single field. Field names depend on the item type (see below) — if you guess wrong, `pass-cli` errors with "Field does not exist".
- `--output json` — full structured dump. Use this to discover the item's content type and field layout before grabbing specific fields.

### Item content types (what to expect in JSON)

The item's payload lives at `.item.content.content.<TypeName>`. Common shapes:

- **`Login`** — credentials. Top-level keys typically include `username`, `password`, `urls`, `totp_uri`. Extra fields under `.item.content.extra_fields[]`.
- **`Note`** — a free-form note. Look at `.item.content.note`. Anything can be in the note body — passphrases, recovery codes, pasted PGP/SSH key blocks, etc. The user's GPG keys are stored as a `Note` with the public + private PGP blocks pasted in.
- **`SshKey`** — has `private_key`, `public_key` fields directly under the type. (Note: not all keys live here — check `Note` items too.)
- **`CreditCard`** — card number, CVV, expiry, holder.
- **`Identity`** — personal-info form items.

Always inspect the JSON first if you don't know the layout:

```bash
pass-cli item view --vault-name Personal --item-id '<id>' --output json \
  | python3 -c "import json,sys; d=json.load(sys.stdin)['item']['content']; print('type:', list(d['content'].keys())); print('extra:', [f['name'] for f in d.get('extra_fields',[])])"
```

## Searching for an item by content

`pass-cli` has no full-text search. Workflow:

1. `pass-cli item list <vault>` to get titles and IDs
2. `grep` titles for what you want
3. `pass-cli item view --output json` to confirm contents

For very broad searches, dump every item's JSON via a loop, but that's slow for large vaults — prefer narrowing by title first.

## Modifying items

```bash
pass-cli item create  ...      # create new item (see --help for type-specific flags)
pass-cli item update  ...      # update fields
pass-cli item trash --vault-name <vault> --item-id '<id>'      # move to trash
pass-cli item untrash ...      # restore from trash
pass-cli item delete  ...      # permanently delete (irreversible)
pass-cli item move    ...      # move to another vault
```

Always confirm with the user before `delete`, `update`, or `move` — these are destructive or hard to reverse. `trash` is recoverable, so it's safer.

## Secrets handling rules (READ THIS)

Items often contain passwords, private keys, recovery codes, etc. When extracting them:

- **Never print a secret to terminal output unless the user explicitly asked for it.** That includes `head`/`cat` of JSON output that contains it. Pipe straight into the consumer (e.g. `gpg --import`, `ssh-add`, a file with `umask 077`).
- Prefer `--field` when you only need one piece, so the rest of the item never crosses your transcript.
- For multi-line blobs in `note` (PGP keys, etc.), pipe the JSON through `python3 -c "import json,sys; print(json.load(sys.stdin)['item']['content']['note'])"` directly into the destination tool. Do not write to a file unless required.
- If you do write to disk, use `mktemp` with mode 0600 and remove the file when done.
- **Never paste a secret into a commit message, log, or chat reply** — even if the secret was just produced.

## Other useful subcommands

```bash
pass-cli password generate          # generate a strong password
pass-cli password score 'foo'       # rate a password's strength
pass-cli totp generate ...          # generate a TOTP code
pass-cli ssh-agent load             # load SSH keys from Pass into the system ssh-agent
pass-cli ssh-agent debug            # explain why an SshKey item isn't loadable
pass-cli inject -i template -o out  # render a file by substituting `{{ pass:... }}` references
pass-cli run -- <cmd>               # run <cmd> with secrets injected as env vars (masks output)
```

`inject` and `run` use `pass://SHARE_ID/ITEM_ID[/FIELD]` URIs — same form as `item view` accepts as a positional argument. Get the share ID from `pass-cli vault list`.

## Quick recipes

**Find and import a GPG key:**
```bash
pass-cli item list Personal 2>/dev/null | grep -i gpg     # locate the active item id
pass-cli item view --vault-name Personal --item-id '<id>' --output json \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['item']['content']['note'])" \
  | gpg --batch --import
```

**Look up a login by title:**
```bash
pass-cli item view --vault-name Personal --item-title 'AWS Console' --field password
```

**Trash an item the user wants to remove:**
```bash
pass-cli item trash --vault-name Personal --item-id '<id>'
```

## Troubleshooting

- `Please provide either --share-id, --vault-name, or set a default vault` — `item list` wants the vault as a positional arg; other subcommands want `--vault-name`.
- `Field does not exist: <name>` — wrong field for this item's content type. Dump `--output json` and look at the actual key names.
- `unexpected argument '--vault-name' found` on a subcommand — that command takes the vault positionally instead. Re-check `--help`.
- Multiple items with the same title — use `--item-id` and check the `state=Active` line from `item list`.
- Auth errors after long inactivity — session expired; ask the user to run `! pass-cli login` (extra-password prompt is interactive).
