#! /bin/bash

# Script that validates all URL on OSM elements on the website key.
# Currently hardcoded to the following area that correspond to Bogota:
# 4.702983,-74.081650,4.725736,-74.027920
#
# Based on https://www.openstreetmap.org/user/Cascafico/diary/401794 Cascafico.
#
# Author: Andres Gomez
# Version: 2023-07-13

CSV_FILE=mylist.csv
QUERY_FILE=query.op

cat <<EOF > query.op
[out:csv(::id,::type,"name","website"; false; ",")];
nwr["website"](4.702983,-74.081650,4.725736,-74.027920);
out ;
EOF

wget -O "${CSV_FILE}" --post-file=${QUERY_FILE} "https://overpass-api.de/api/interpreter" > /dev/null
if [ ${?} -ne 0 ] ; then
 echo "There was an error in the Overpass query."
fi

rm "${QUERY_FILE}"

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
 QTY=$(echo "${URL}" | grep -i facebook | wc -l)
 if [ "${QTY}" -ne 0 ] ; then
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

