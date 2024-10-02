### Setting the dbus machine id

#### Why is this feature useful?

Packages like [node-machine-id](https://www.npmjs.com/package/node-machine-id) rely on the dbus machine id.

Some software that requires a licence, rely on those packages. To avoid problems with those registration on rebuilds of your devcontainer, you can persist a machine id with this feature.
