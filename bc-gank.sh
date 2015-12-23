#!/bin/bash
DIR=`echo "$ARTIST"-"$ALBUM" | sed 's/ /_/g'`
/opt/youtube-dl/youtube-dl --restrict-filenames -j $1 > /tmp/scrape.json
# artist name.  not included in json so curl and grab it from the html, set as variable
ARTIST=`curl -s $1 | grep -m1  -i "artist:" | tr -d ',' | tr -s ': ' ':' | awk -F':' '{print $3}'`
# album name
ALBUM=`jq '.playlist_title' /tmp/scrape.json | grep -m1 '"'`
DIR=`echo "/tmp/"$ARTIST-$ALBUM | tr -d '"' | sed 's/ /_/g'`
mkdir $DIR
cd $DIR
# DL album cover and resize it 50 percent
curl -o big.jpg `curl -s $1 | grep   -i 'artFullsizeUrl' | tr -d '"' | tr -d ',' | awk -F' ' '{print $2}'`
convert big.jpg -resize 50% "$DIR/folder.jpg"
jp2a --width=75 --colors "$DIR/folder.jpg" > /tmp/ascii.art
# create list of stream urls to curl
jq '.url' /tmp/scrape.json > $DIR/url.info
#curl -s $1 | grep 'mp3' | sed 's/    trackinfo : //g' | sed 's/.$//' | jq '.[] | .file' | grep mp3 | awk '{print $2}' > $DIR/url.info
# create filename list for tagging id3 
jq '._filename' /tmp/scrape.json > $DIR/filename.info
# create list of titles to id3tag per filename
jq '.title' /tmp/scrape.json > $DIR/title.info
# create list of genera tags for id3 
curl -s $1 | grep -i 'itemprop="keywords" rel="nofollow"' | tr -s ' ' ',' | tr -d '"' | tr -s '/' ',' | awk -F',' '{print $7}' > $DIR/tags.info
TRACKCOUNT=`wc -l < "$DIR"/url.info`
TR=`expr $TRACKCOUNT + 1`
# set up out general purpose counter
LINE=0
#/opt/youtube-dl/bin/youtube-dl --restrict-filenames $1
ALBUMT=`echo $ALBUM | tr -d '"'`
ARTISTT=`echo $ARTIST | tr -d '"'`
while [ "$LINE" -lt "$TRACKCOUNT" ]
do
        LINE=`expr $LINE + 1`
	FTITLE=`sed ''$LINE'q;d' filename.info | tr -d '"'`
        URL=`sed ''$LINE'q;d' url.info | tr -d '"'`
	curl -s -L "$URL" > "$DIR"/"$FTITLE" &
done
#COUNT=`pgrep -f curl -c`
# define jthe amount of processes we know are remaining. ouput the curl processes still remaining in psudo realtime  untill they complete
while [ "$COUNT" != "0" ]
do
        COUNT=`pgrep -f curl -c`
	clear
	cat /tmp/ascii.art
        echo ""
        echo "    .: Grabbing $ALBUMT by $ARTISTT ($COUNT of $TRACKCOUNT left to go...) :."
	echo " "
	echo "    .: Tracklisting :. "
	cat -b "$DIR"/title.info
        sleep 1
done
# reset our handy counter
LINE=0
echo "Downloaded!  Tagging mp3s..."
# tag3 our mp3s
while [ "$LINE" -lt "$TRACKCOUNT" ]
do
        LINE=`expr $LINE + 1`
        URL=`sed ''$LINE'q;d' url.info`
        TITLE=`sed ''$LINE'q;d' title.info | tr -d '"'`
	FTITLE=`sed ''$LINE'q;d' filename.info | tr -d '"'`
	# still working on how to tag multiply tags.. for now im just choosing to use the second tag i grab.
	SINGLETAG=`head -n 1 tags.info | tr -d '"'`
	eyeD3 -2 --add-image="$DIR/"folder.jpg:FRONT_COVER -G "$SINGLETAG" -t "$TITLE" -a "$ARTISTT" -A "$ALBUMT" -n "$LINE" "$DIR"/$FTITLE | grep -m1 "mp3" | tr -s '\t' ' '
done
