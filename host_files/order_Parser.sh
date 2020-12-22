#!/bin/bash

FILES=/hdd/TMA/logs/*
for f in $FILES
do
    sed '/========== RESPONSE ==========/,/========== END ==========/d' $f > "$fParsed"
done

mv EU_* EU
mv NA_* NA
mv AU_* AU
mv SG_* SG

echo -n "Done!"