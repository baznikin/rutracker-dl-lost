#!env bash

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit
fi

FORUM=$1
TARGET_PATH=$(realpath "$2" 2>/dev/null)

SCRIPT_PATH=$(dirname `realpath $0`)

if [ -z "$TARGET_PATH" ]; then
    echo "Target path not found"
    exit
fi

source ${SCRIPT_PATH}/rutracker.cred

if [ -z "$USER" ]; then
    echo "RuTracker username not found"
    exit
fi

if [ -z "$PASS" ]; then
    echo "RuTracker password not found"
    exit
fi

echo "FORUM: $FORUM -> $TARGET_PATH"


CURL_OPTS="-sS --retry 5 --retry-connrefused -b ${SCRIPT_PATH}/.cookie -c ${SCRIPT_PATH}/.cookie ${PROXY}"

echo "Loggin in"
LOGIN_REQUEST="-F redirect=privmsg.php -F login_username=${USER} -F login_password=${PASS} -F login=%C2%F5%EE%E4"

OUT=`curl ${CURL_OPTS} ${LOGIN_REQUEST} https://rutracker.org/forum/login.php`

if [ ! -z "$OUT" ]; then
    echo "Can't login for some reason"
    exit
fi

INDEX_PAGE=`curl ${CURL_OPTS} "https://rutracker.org/forum/tracker.php?tm=-1&o=10&s=1&oop=1&f=${FORUM}"`

TOKEN=$(echo $INDEX_PAGE | grep -oE "form_token: '\w+'" | grep -oE '\w+' | tail -1)
SEARCH_ID=$(echo $INDEX_PAGE | grep -oE "PG_BASE_URL: 'tracker.php\?search_id=\w+'" | grep -oE '\w+' | tail -1)
SEARCH_RESULTS=$(echo $INDEX_PAGE | grep -oE ': [0-9]+ <span class="normal">\(max:' | grep -oE "[0-9]+")

echo "${SEARCH_RESULTS} results. Processing..."

i=0
while [ $i -lt $SEARCH_RESULTS ]
do

  page=0
  while [ $page -lt 50 ]
  do
    if [ "$i" = "0" ]; then
      # we already fetch first page
      OUT=$INDEX_PAGE
    else
      OUT=`curl ${CURL_OPTS} "https://rutracker.org/forum/tracker.php?search_id=${SEARCH_ID}&start=${i}"`
      echo "Get next 50 results starting with ${i}"
    fi

    set -- $(echo $OUT | grep -oE 'href="dl.php\?t=[0-9]+">.+</a> </td> <td class="row4 nowrap" data-ts_text="-?[0-9]+">' | grep -oE '"[^"]+"' | grep -v nowrap)
    while [ "$#" -gt 0 ]
    do
      URL=$( echo $1 | tr -d \"-)
      DAYS=$( echo $2 | tr -d \"-)
      ID=$(echo $URL | tr -Cd 0-9)
      echo "Result #$page ($i total) [ID=$ID, absent for $DAYS days]"

      if [ -e "$TARGET_PATH/$ID.torrent" ]; then
        echo "- Already exists, skipping"
      else
        if [ $(echo "DAYS" | grep -v "-") = "" ]; then
          echo "- There is ${DAYS} seeder(s) at moment, fetching anyway"
        fi

        echo "- Fetching"
        RES=`curl  --fail -w 'Return code: %{http_code}' ${CURL_OPTS} -d form_token=$TOKEN -o "$TARGET_PATH/$ID.torrent" "https://rutracker.org/forum/$URL"`

        # TODO - check it downloaded OK
        if [ "$RES" = "Return code: 200" ]; then
          # callback script to feed torrent file to your BitTorrent client
          if [ -x "$SCRIPT_PATH/add_torrent.sh" ]; then
            echo `$SCRIPT_PATH/add_torrent.sh "$ID" "$DAYS" "$TARGET_PATH/$ID.torrent"`
          fi
        else
          echo "- Fetch error!"
        fi
      fi

      shift 2
      true $((i=i+1))
      true $((page=page+1))
    done
    if [ "$page" = "0" ]; then
      echo "No results, exiting."
      exit
    fi
  done
done