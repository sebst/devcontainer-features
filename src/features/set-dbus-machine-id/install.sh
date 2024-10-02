#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

DBUS_MACHINE_ID_FILE=/var/lib/dbus/machine-id
DBUS_NEW_MACHINE_ID=$MACHINE_ID

if [ -f "$DBUS_MACHINE_ID_FILE" ]; then
  echo "Old dbus machine ID found: $(cat $DBUS_MACHINE_ID_FILE)"
fi

echo "Setting dbus machine ID to $DBUS_NEW_MACHINE_ID"
echo "$DBUS_NEW_MACHINE_ID" > $DBUS_MACHINE_ID_FILE
