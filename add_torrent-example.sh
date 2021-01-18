#!env bash

# Example script to add torrent to your torrent client
# It takes 3 parameters
# - path to .torrent file
# - path to download torrent to
# - days since full seed was online (can be used as priority)

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    exit
fi

ID=$1
DAYS=$2	# if your torrent client allow you to specifiy priority - you can use it

TORRENT_PATH=$(realpath "$3" 2>/dev/null)			# /mnt/tank/share/music/RUTracker-Keepers/2287-jazz/.torrents/1234688.torrent
TARGET_PATH=$(realpath `dirname $TORRENT_PATH`/..)		# /mnt/tank/share/music/RUTracker-Keepers/2287-jazz
INCOMPLETE_PATH="$(realpath $TARGET_PATH)-incomplete"	# /mnt/tank/share/music/RUTracker-Keepers/2287-jazz-incomplete

if [ -z "$TORRENT_PATH" ]; then
    echo "Torrent file not found"
    exit
fi

mkdir -p "${INCOMPLETE_PATH}/${ID}"

DL_TARGET=$(echo $TARGET_PATH | sed -E "s/\/mnt\/tank\/share\/music\/RUTracker-Keepers/\/Shared\/RUTracker-Keepers/")	# /Shared/RUTracker-Keepers/2287-jazz
DL_INCOMPLETE=$(echo $INCOMPLETE_PATH | sed -E "s/\/mnt\/tank\/share\/music\/RUTracker-Keepers/\/Shared\/RUTracker-Keepers/")
DL_TORRENT=$(echo $TORRENT_PATH | sed -E "s/\/mnt\/tank\/share\/music\/RUTracker-Keepers/\/Shared\/RUTracker-Keepers/")


# !!
# Your actuall torrent client call here:
OUT=`iocage exec deluge "LANG=ru_RU.UTF-8 deluge-console -c /usr/local/etc/deluge/ 'add -m ${DL_TARGET}/${ID}/ -p ${DL_INCOMPLETE}/${ID}/ ${DL_TORRENT}'"`;

# Make output simpler
if [ "$(echo "$OUT" | grep "Torrent added")" != "" ]; then
 echo "OK"
else
  echo "FAILED: $OUT"
fi