#!/bin/sh

#vstupní soubor
IN=$(uci get recorder.@recorder[0].directory)

#výstupní soubor
OUT=$IN"/nahledy/"

LOMITKO='/'
TS='.TS'
JPG='.jpg'
CAS='00:12:01.01'
ROZLISENI='320*240'
TIMEOUT='30'

generuj_obrazek()
{
	VSTUP=$IN$LOMITKO$POLOZKA
	POLOZKA=$(echo $POLOZKA | sed -e "s/.ts//g")
	echo "$POLOZKA"
	VYSTUP=$OUT$POLOZKA$JPG
	echo "$VSTUP"
	ffmpeg -ss "$CAS" -i "$VSTUP" -y -s "$ROZLISENI" -f image2 \-vcodec mjpeg -vframes 1 "$VYSTUP"
} 

if [ "$#" -ne 2 ]; then
	echo -e "Generovaní náhledu jedné nahrávky.\n"
	POLOZKA=$1
	generuj_obrazek
else
	if [ "$#" -ne 3 ]; then
		POLOZKA=$1
		CAS=$2
		generuj_obrazek
	else
		ls $IN | grep '\.ts$' | while read POLOZKA
		do
			if [ -f "$IN/$POLOZKA" ]
			then
				VSTUP=$IN$LOMITKO$POLOZKA
				POLOZKA=$(echo $POLOZKA | sed -e "s/.ts//g")
				VYSTUP=$OUT$POLOZKA$JPG
				echo "$VSTUP"
				ffmpeg -ss "$CAS" -i "$VSTUP" -y -s "$ROZLISENI" -f image2 \-vcodec mjpeg -vframes 1 "$VYSTUP" &
				ID_PROCESU=$!
				sleep "$TIMEOUT"
				kill $ID_PROCESU
			fi
		done
	fi
fi
