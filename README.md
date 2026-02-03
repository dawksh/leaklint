# leaklint

Pre-commit hook that scans staged changes for secrets and blocks commits when matches are found.

## Install

Copy `hook.sh`, `install.sh`, and `patterns.json` into your repo, then run:

```bash
./install.sh
```

This installs the pre-commit hook into `.git/hooks/pre-commit` and copies patterns to `.secret-guard-patterns.json`.

## How it works

On each `git commit`, the hook runs `git diff --cached` and checks added lines against regex patterns. If any match, the commit is blocked.

## Exceptions

To allow a specific secret, add a `//allow-leaky` comment on the same line or the line immediately after the secret:

```javascript
const apiKey = "sk-1234567890abcdef"; //allow-leaky
```

or

```javascript
const apiKey = "sk-1234567890abcdef";
//allow-leaky
```

## Default patterns

| Pattern          | Example                     |
|------------------|-----------------------------|
| AWS Access Key   | `AKIA...`                   |
| AWS Secret Key   | Various formats             |
| OpenAI API Key   | `sk-...`                    |
| Stripe API Key   | `sk_live_...`               |
| GitHub Token     | `ghp_...`                   |
| Private Key      | `-----BEGIN ... PRIVATE KEY-----` |
| JWT              | `eyJ...`                    |

## Custom patterns

Edit `.secret-guard-patterns.json` after install. Each key is the label shown on match; the value is the regex.

```json
{
  "My Secret": "my-secret-[a-z0-9]{32}"
}
```

## Dependencies

- `jq` for JSON parsing
- `grep` with `-E` (extended regex)
