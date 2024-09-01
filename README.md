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
 - [jq](https://github.com/jqlang/jq) (only needed for `--json` option)

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

Note that some options are specific to certain sites (like sorting), you can read about it by typing

    torge SOURCE -h

Universal options are described in

    torge -h

Search sorting by date

    torge 1337x -s date iso

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

Output search results in csv (by default delimited by `\t`, can be changed with `-D` option)

    torge SOURCE --csv -D '\t' your search query

The first line printed will be a csv header unless `--no-csv-header` option is used.

Note that most sites do not store magnet links in search pages and by default the above returns whatever links it finds. If you want to ensure that you get magnet links (or links in case of `libgen`) use `--link-conv` option with `--csv`. Although there will be noticable delay as this will go through all pages (but only if necessary).

Output serch results in json (`--link-conv` also works with it)

    torge SOURCE --json your search query

Resulting json will have `link` field being search page from which results were taken, `site` field naming site, and `results` array. Dictionaries in `results` array have fields depending only on `site` e.g. `thepiratebay` has `author` field but `limetorrents` does not.

For example running

    torge tpb --json linux iso | jq .

will return

```json
{
  "link": "https://tpb.party/search/linux.iso/1/7/0",
  "site": "thepiratebay",
  "results": [
    {
      "category": "Windows",
      "size": "2.92 GiB",
      "date": "02-18-2019",
      "name": "Kali Linux 64 Bit 2018.4 - 3GB-ISO",
      "seeders": "9",
      "leechers": "0",
      "author": "AdithyaA",
      "link": "magnet:?xt=urn:btih:1A17DF934566F21B12489987F070671223B23A9D&dn=Kali+Linux+64+Bit+2018.4+-+3GB-ISO&tr=http%3A%2F%2Fp4p.arenabg.com%3A1337%2Fannounce&tr=udp%3A%2F%2F47.ip-51-68-199.eu%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2780%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2730%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2920%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Fopentracker.i2p.rocks%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.cyberia.is%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.dler.org%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=udp%3A%2F%2Ftracker.pirateparty.gr%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.tiny-vps.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce"
    },
    {
      "category": "UNIX",
      "size": "2.74 GiB",
      "date": "01-29-2016",
      "name": "Kali Linux Amd64, [Iso - MultiLang] [TNTVillage]",
      "seeders": "4",
      "leechers": "1",
      "author": "mykons",
      "link": "magnet:?xt=urn:btih:5AEC5EE9F2D044316FE1DE29D221452103CEB958&dn=Kali+Linux+Amd64%2C+%5BIso+-+MultiLang%5D+%5BTNTVillage%5D&tr=http%3A%2F%2Fp4p.arenabg.com%3A1337%2Fannounce&tr=udp%3A%2F%2F47.ip-51-68-199.eu%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2780%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2730%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2920%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Fopentracker.i2p.rocks%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.cyberia.is%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.dler.org%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=udp%3A%2F%2Ftracker.pirateparty.gr%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.tiny-vps.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce"
    },
  ]
}
```

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

![example2](example2.gif)
