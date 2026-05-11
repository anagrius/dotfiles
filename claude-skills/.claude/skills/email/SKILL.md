---
name: email
description: Search, read, and send Gmail (or any IMAP/SMTP) email from the terminal using the `himalaya` CLI. Use this skill whenever the user asks to check email, find emails, search Gmail/IMAP, read messages, download attachments, or send mail. Triggers include "find email", "search gmail", "check inbox", "read mail", "download attachment", "send email", "imap", "himalaya", or any reference to mail operations from the command line.
---

# Email Skill (himalaya)

The `himalaya` CLI manages email over IMAP/SMTP. This skill covers Gmail search, message reading, attachment download, and sending — the user's account is `borlum@gmail.com` over Gmail IMAP, with `thomas@anagri.us` as a send-as alias.

## Prerequisites

- `himalaya` is installed (Arch `extra`: `sudo pacman -S himalaya`). Verify with `himalaya --version`.
- Config lives at `~/.config/himalaya/config.toml` and authenticates via a Gmail **app password** stored in Proton Pass (`Personal` vault, item title `Gmail IMAP App Password (himalaya)`). Himalaya fetches it on demand via `pass-cli`.
- If auth fails, the app password may have been revoked. The user must regenerate one at https://myaccount.google.com/apppasswords (Gmail account `borlum@gmail.com`) and update the Proton Pass item with `pass-cli item update --vault-name Personal --item-title "Gmail IMAP App Password (himalaya)" --field password <new>`. Tell the user — don't try OAuth XOAUTH2.

The current config (for reference, do not rewrite blindly):

```toml
[accounts.gmail]
default = true
email = "borlum@gmail.com"

[accounts.gmail.folder.alias]
inbox = "INBOX"
sent = "[Gmail]/Sent Mail"
drafts = "[Gmail]/Drafts"
trash = "[Gmail]/Trash"

[accounts.gmail.backend]
type = "imap"
host = "imap.gmail.com"
port = 993
encryption.type = "tls"
login = "borlum@gmail.com"

[accounts.gmail.backend.auth]
type = "password"
cmd = "pass-cli item view --vault-name Personal --item-title 'Gmail IMAP App Password (himalaya)' --field password"
```

## Searching for emails

```bash
himalaya envelope list -f "[Gmail]/All Mail" -s 30 '<query>'
```

- **Default folder is `INBOX`** — older mail is archived. For most "find this email" tasks, search `[Gmail]/All Mail` instead.
- `-s` is page size (default ~10). `-p N` for page N.
- Output columns: ID, FLAGS, SUBJECT, FROM, DATE.
- The `WARN ... Rectified missing 'text'` log lines on stderr are harmless (Gmail IMAP quirk).

### Query syntax (custom, NOT raw IMAP)

Conditions: `subject <pat>`, `body <pat>`, `from <pat>`, `to <pat>`, `date YYYY-MM-DD`, `before YYYY-MM-DD`, `after YYYY-MM-DD`, `flag <flag>`. Combine with `and`, `or`, `not`. Patterns with spaces need double quotes: `subject "order confirmation"`.

Append a sort: `order by date desc subject`.

Example:

```bash
himalaya envelope list -f "[Gmail]/All Mail" -s 30 \
  'subject Aspire or body Aspire'

himalaya envelope list -f "[Gmail]/All Mail" -s 20 \
  'from amazon and subject "your order" and after 2025-01-01'
```

### Gotchas

- **Non-ASCII characters break the query parser** (e.g. Swedish `ä`/`ö`/`å`). Workarounds: quote the term, drop the diacritics, or search in the body without the accented word — `subject kvitto` works, `subject "köpskydd"` returns `Could not parse command`.
- The query is passed to IMAP `SEARCH`; very large `or` chains can also produce `BAD response: Could not parse command`. Keep clauses small or split into multiple runs.
- IDs returned by `envelope list` are folder-local — re-pass the same `-f <folder>` to `message read`/`attachment download`.

## Reading a message

```bash
himalaya message read -f "[Gmail]/All Mail" <ID>
```

Shows headers (From/To/Subject) and decoded body. HTML emails come as `<#part type=text/html>` blocks; binary attachments as `<#part type=... filename=...>` blocks (use the attachment subcommand to actually save them).

`message read --help` for raw / preview-text / no-headers variants.

## Downloading attachments

```bash
himalaya attachment download -f "[Gmail]/All Mail" <ID>
```

Saves all attachments from the message to himalaya's downloads dir (configurable in `config.toml` via `downloads-dir`). After downloading, read PDFs/etc. with the `Read` tool.

## Sending mail

`himalaya message send` takes a **raw RFC 2822 message** on stdin or as args:

```bash
himalaya message send <<'EOF'
From: Thomas Anagrius <thomas@anagri.us>
To: recipient@example.com
Subject: Hello

Body text here.
EOF
```

Use `From: thomas@anagri.us` by default — that's the user's preferred public-facing address. The underlying account is `borlum@gmail.com` (Gmail IMAP/SMTP). For richer composition (multipart, attachments, drafts), see `himalaya template` and `himalaya message write`.

## Folders

```bash
himalaya folder list                      # list all folders
himalaya folder list -a gmail             # explicit account
```

Gmail folder names use the `[Gmail]/...` prefix: `[Gmail]/All Mail`, `[Gmail]/Sent Mail`, `[Gmail]/Drafts`, `[Gmail]/Trash`, `[Gmail]/Spam`, `[Gmail]/Important`, `[Gmail]/Starred`. Labels appear as folders too.

## Output formats

- Default: human-readable table.
- `-o json`: JSON output (good for scripting / parsing IDs).

## Multi-account

Only the `gmail` account is configured today. To add another, append a new `[accounts.<name>]` block to `config.toml` and select it with `-a <name>`. `default = true` only on one.
