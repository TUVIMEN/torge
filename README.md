# torge

A shell script for searching for links on torrent sites.

![example](example.gif)

## Supported sites

 - thepiratebay
 - limetorrents
 - rarbg (as for now getting magnet link is being blocked by cloudflare)
 - nyaa
 - 1337x
 - libgen

## Requirements

 - [reliq](https://github.com/TUVIMEN/reliq)
 - xclip

## Installation

    install -m 755 torge /usr/bin

## Aliases

It's quite beneficial to alias sites in your config to avoid needless typing, here's a list of proposed ones:

    alias tpb='torge tpb'
    alias libgen='torge libgen'
    alias limetorrents='torge lt'
    alias nyaa='torge nyaa'
    alias 1337x='torge 1337x'
    alias rarbg='torge rarbg'

## Usage

Just type 'torge source your search', choose what you want and the link will be copied to your clipboard. You can choose multiple results by reparating their line number with space.

Note that some options are specific to certain sites, you can read about it by typing.
    torge -h

    torge source -h

Search for the smallest linux isos on thepiratebay

    torge tpb -s size -r linux iso

Search different domain for linux isos and change delimiter to space

    torge tpb -D ' ' -d 'http://otherdomain.to' 'linux iso'

Search for the biggest lossless audio

    torge nyaa -c audio-lossless -s size audio

Search for scientific articles about evolution on 2nd page

    torge libgen -p 2 -m science evolution

Search for Lovecraft's fiction in pdf format

    torge libgen -F pdf -m fiction lovecraft

Search search for 'The Road to Serfdom' ordered by size, reversed

    torge libgen -r -o size the road to serfdom

My fzf integration that adds magnets to transmission-remote or copies wget command downloading the books into the clipboard

```shell
ftorge() {
    res="$(torge "$@" --no-clipboard --no-prompt --choose 'fzf --ansi --multi | cut -f1 | paste -sd ,')"
    [ "$?" -ne '0' ] && return
    if [ "$1" = 'libgen' ]
    then
        {
        echo -n 'wget '
        sed "s/^/'/;s/$/'/" <<< "$res" | paste -sd ' '
        } | xclip -r -sel clip
    else
        for i in $res
        do
            transmission-remote -a "$i"
        done
    fi
}
```
