#! /bin/bash

# Script that validates all URL on OSM elements on the website key.
# Currently hardcoded to the following area that correspond to some area at
# the north of Bogota:
# 4.702983,-74.081650,4.725736,-74.027920
#
# Based on https://www.openstreetmap.org/user/Cascafico/diary/401794 Cascafico.
#
# Author: Andres Gomez
# Version: 2023-07-13

CSV_FILE=mylist.csv
QUERY_FILE=query.op
declare -A WEBSITES

cat <<EOF > query.op
[out:csv(::id,::type,"name","website"; false; ",")];
nwr["website"](4.702983,-74.081650,4.725736,-74.027920);
out ;
EOF

if ! wget -O "${CSV_FILE}" --post-file=${QUERY_FILE} "https://overpass-api.de/api/interpreter" > /dev/null ; then
 echo "There was an error in the Overpass query."
fi

rm "${QUERY_FILE}"

echo "| Code | Explanaition"
echo "+------+------------------"
echo "| 103  | OK"
echo "| 200  | OK"
echo "| 301  | Moved permanently"
echo "| 302  | Found"
echo "| 307  | "
echo "| 403  | Forbidden"
echo "| 404  | Not found"
echo "| 500  | Internal Server Error"

echo "Please copy the following table in the OSM wiki - https://wiki.openstreetmap.org/. You can preview the table meanwhile you correct the URLs."
echo
echo "========================================================================"
echo 

cat << EOF
{| class="wikitable"
|+
!Name
!URL
!OSM Element
!reply
EOF

while IFS="," read -r OSMid OSMtype OSMname URL ; do
 if [ ! -v 'WEBSITES[${URL}]' ] ; then
  REPLY=$(curl --silent --head "${URL}" | awk '/^HTTP/{print $URL}' | tr -d "\n" | tr -d "\r")
  WEBSITES[${URL}]=${REPLY}
 else
  REPLY=${WEBSITES[${URL}]}
 fi
 if [ "${REPLY}" != "HTTP/2 200 " ] \
   && [ "${REPLY}" != "HTTP/1.1 200 OK" ] \
   && [ "${REPLY}" != "HTTP/1.0 200 OK" ] \
   && [ "${REPLY}" != "HTTP/1.1 200 " ] \
   && [ "${REPLY}" != "HTTP/2 103 HTTP/2 200 " ] ; then
  cat << EOF
|-
| ${OSMname}
| ${URL}
| https://www.openstreetmap.org/${OSMtype}/${OSMid}
| ${REPLY}
EOF
 fi
done < "${CSV_FILE}"
echo "|}"

rm "${CSV_FILE}"

