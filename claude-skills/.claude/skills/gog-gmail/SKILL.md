---
name: gog-gmail
description: Search Gmail, read emails, and download attachments using the gog CLI. Use this skill whenever the user asks to check email, find emails, search Gmail, read messages, download email attachments, or interact with their Gmail account via the terminal. Also use when the user mentions gog, gog cli, or references gmail operations from the command line.
---

# gog Gmail Skill

The `gog` CLI is a Google API client that provides terminal access to Gmail (and other Google services). This skill covers Gmail search, message reading, and attachment downloading.

## Prerequisites

The user must have `gog` installed and authenticated. If a command fails with a token error like `"invalid_grant" "Token has been expired or revoked."`, the user needs to re-authenticate:

```bash
gog login <email>
```

This opens a browser OAuth flow. You cannot do this non-interactively — ask the user to run it themselves (e.g. `! gog login <email>`).

To check which accounts are configured:

```bash
gog auth list
```

## Searching for emails

Search threads (grouped conversations) using Gmail query syntax:

```bash
gog gmail search "<query>" --max=<N>
```

- `<query>` uses standard Gmail search operators: `from:`, `to:`, `subject:`, `has:attachment`, `after:`, `before:`, `is:unread`, `label:`, etc.
- `--max=10` is the default; adjust as needed
- `--page=<token>` for pagination (the token is printed in the output)
- `--all` fetches all pages
- Output columns: ID, DATE, FROM, SUBJECT, LABELS, THREAD

To search individual messages instead of threads:

```bash
gog gmail messages search "<query>" --max=<N>
```

The messages search also supports `--include-body` to include the decoded message body in the output.

### Common search examples

```bash
# Emails from a person
gog gmail search "from:anna-carin" --max=5

# Unread emails with attachments
gog gmail search "is:unread has:attachment" --max=10

# Emails in a date range
gog gmail search "from:boss after:2026/03/01 before:2026/04/01"

# By subject
gog gmail search "subject:invoice" --max=5
```

## Reading a message

To read the full content of a message, use the message ID from search results:

```bash
gog gmail get <messageId>
```

This prints headers (from, to, cc, subject, date) and the decoded body text. Attachments are listed with their filename, size, MIME type, and attachment ID.

Options:
- `--format=full` (default) — full message with body
- `--format=metadata` — headers only
- `--format=raw` — raw RFC 2822
- `-j` / `--json` — JSON output for scripting

## Downloading attachments

Attachments are listed in the output of `gog gmail get`. Each attachment shows a filename, size, and an attachment ID (a long opaque string).

```bash
gog gmail attachment <messageId> <attachmentId> --out <path>
```

- `--out` sets the output file path. If pointing to a directory, use `--name` to set the filename.
- Without `--out`, saves to the gogcli config directory.

After downloading, you can read PDFs with the Read tool or process other file types as needed.

### Workflow example: find and download an attachment

```bash
# 1. Search for the email
gog gmail search "from:anna-carin has:attachment" --max=3

# 2. Read the message to see attachment details
gog gmail get 19d6c09ed100def3

# 3. Download the attachment (use the attachment ID from step 2)
gog gmail attachment 19d6c09ed100def3 "ANGjdJ9I..." --out /tmp/invoice.pdf
```

## Sending mail

Send an email with `gog gmail send`:

```bash
gog gmail send \
  --account borlum@gmail.com \
  --from thomas@anagri.us \
  --to recipient@example.com \
  --subject "Hello" \
  --body "Body text"
```

**Default send-as:** unless the user specifies otherwise, send as `thomas@anagri.us` via `--from thomas@anagri.us`. The underlying Gmail account is `borlum@gmail.com` (passed via `--account`), but `thomas@anagri.us` is the preferred public-facing address. `--from` must be a verified send-as alias on that account — list them with `gog gmail settings sendas list --account borlum@gmail.com`.

Useful flags: `--cc`, `--bcc`, `--body-html`, `--body-file=-` (read body from stdin), `--attach <path>` (repeatable), `--reply-to-message-id <id>` to thread a reply.

## Multi-account usage

If multiple accounts are configured, specify which one with `-a`:

```bash
gog gmail search "from:someone" -a other@gmail.com --max=5
```

## Output formats

- Default: human-readable colored table/text
- `-p` / `--plain`: TSV, stable for parsing
- `-j` / `--json`: full JSON output
- `--results-only`: in JSON mode, omits envelope fields like nextPageToken
- `--select=<fields>`: in JSON mode, select specific fields (dot paths supported)

## Other useful Gmail commands

```bash
# Get a web URL for a thread
gog gmail url <threadId>

# Archive messages
gog gmail archive <messageId>

# Mark as read/unread
gog gmail mark-read <messageId>
gog gmail unread <messageId>

# List/manage labels
gog gmail labels list
```
