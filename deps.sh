#!/bin/bash
curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
chmod a+x /usr/local/bin/youtube-dl
curl --header 'Host: stedolan.github.io' --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0 Iceweasel/31.4.0' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header 'Accept-Language: en-US,en;q=0.5' --header 'Referer: http://stedolan.github.io/jq/' --header 'Connection: keep-alive' 'http://stedolan.github.io/jq/download/linux64/jq' -o 'jq' -L
chmod +x jq
mv jq /usr/bin/
apt-get install -y jp2a eyeD3
