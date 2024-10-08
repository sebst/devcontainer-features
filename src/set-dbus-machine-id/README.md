
# set-dbus-machine-id (set-dbus-machine-id)

Sets the dbus machine id in `/var/lib/dbus/machine-id`

## Example Usage

```json
"features": {
    "ghcr.io/sebst/devcontainer-features/set-dbus-machine-id:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| machine_id | The machine id to set | string | f6b7d81759f1fa057a196c9766fd1f5c |

### Setting the dbus machine id

#### Why is this feature useful?

Packages like [node-machine-id](https://www.npmjs.com/package/node-machine-id) rely on the dbus machine id.

Some software that requires a licence, rely on those packages. To avoid problems with those registration on rebuilds of your devcontainer, you can persist a machine id with this feature.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/sebst/devcontainer-features/blob/main/src/set-dbus-machine-id/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
