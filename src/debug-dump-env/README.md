
# debug-dump-env (debug-dump-env)

Writes environment variables to `tmp/debug-dump-env`.

## Example Usage

```json
"features": {
    "ghcr.io/sebst/devcontainer-features/debug-dump-env:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| testvar1 | dummy variable | string | testvar1value |

### Dumping the environment during install

#### Why is this feature useful?

Each installation routine of a devcontainer feature is isolated. You might be interested what environment variables are set during installation.

This feature dumps its own environment variables to `/tmp/debug-dump-env`.

This is a debugging feature for feature developers.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/sebst/devcontainer-features/blob/main/src/debug-dump-env/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
