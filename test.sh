#!/bin/sh

SLEEP_TIME=2

assert() {
    if [ "$@" ]
    then
        return
    else
        echo "$@ - failed" >&2
    fi
}

torge() {
    local fields="$1" src="$2" results="$3"
    shift 3
    local t="$(./torge "$src" --csv "$@")"
    local numoffields="$(echo "$t" | head -n 1 | tr -t '\t' '\n' | wc -l)"
    assert "$numoffields" -eq "$fields"
    local ret="$(echo "$t" | tail -n +2)"
    assert "$(echo "$ret" | wc -l)" -eq "$results"
    echo "$ret"

    sleep "$SLEEP_TIME"
}

torge_source() {
    local fields="$1" src="$2" results="$3"
    shift 3

    if echo "$1" | grep -qE '^[0-9]+$'
    then
        results="$1"
        shift
    fi

    torge "$fields" "$src" "$results" "$@"
}

tpb() {
    torge_source 8 tpb 30 "$@"
}

lt() {
    torge_source 7 lt 40 "$@"
}

t1337x() {
    torge_source 7 1337x 20 "$@"
}

rarbg() {
    torge_source 7 rarbg 50 "$@"
}

nyaa() {
    torge_source 8 nyaa 75 "$@"
}

libgen_nf() {
    torge_source 7 libgen 25 "$@" -m nf
}

libgen_f() {
    torge_source 6 libgen 25 "$@" -m f
}

libgen_s() {
    torge_source 5 libgen 25 "$@" -m s
}

field() {
    cut -d "$(printf '\t')" -f "$@"
}

test_tpb() {
    echo tpb standard
    tpb list >/dev/null

    echo tpb name
    assert "$(tpb -s name list | field 4 | grep '^[t-z]' | wc -l)" -ge 28
    echo tpb reverse name
    assert "$(tpb -s name -r list | field 4 | grep '^[0-9]' | wc -l)" -ge 20

    echo tpb size
    assert "$(tpb -s size list | field 2 | grep -E '^[1-9][0-9]+(\.[0-9]+)?\>.\<GiB$' | wc -l)" -ge 20
    echo tpb reverse size
    assert "$(tpb -s size -r list | field 2 | grep -E '^[1-9]+\>.\<B$' | wc -l)" -ge 20

    echo tpb date
    assert "$(tpb -s date list | field 3 | grep -E '(\<[0-9]{2}:[0-9]{2}$|ago)' | wc -l)" -ge 25
    echo tpb reverse date
    assert "$(tpb -s date -r list | field 3 | grep -E '\<200[4-7]$' | wc -l)" -ge 25

    echo tpb se
    assert "$(tpb -s se lord of the rings | field 5 | grep -E '^[0-9]{3,}$' | wc -l)" -ge 20
    echo tpb reverse se
    assert "$(tpb -s se -r lord of the rings | field 5 | grep -Fx '0' | wc -l)" -ge 25

    echo tpb le
    assert "$(tpb -s le lord of the rings | field 6 | grep -E '^[0-9]{2,}$' | wc -l)" -ge 20
    echo tpb reverse le
    assert "$(tpb -s le -r lord of the rings | field 6 | grep -Fx '0' | wc -l)" -ge 25

    echo tpb author
    assert "$(tpb -s author list | field 7 | grep '^z' | wc -l)" -ge 25
    echo tpb reverse author
    assert "$(tpb -s author -r list | field 7 | grep '^Anonymous\>' | wc -l)" -ge 25

    echo tpb category
    assert "$(tpb -s category the | field 1 | grep '^Other > Other' | wc -l)" -ge 25
    echo tpb reverse category
    assert "$(tpb -s category -r the | field 1 | grep '^Audio > Music' | wc -l)" -ge 25

    echo tpb latest
    tpb --latest >/dev/null

    echo tpb magnets
    assert "$(tpb the -s se | field 8 | grep '\<magnet:?' | wc -l)" -ge 30

    echo tpb categories
    local t="$(tpb -c audio,other -s se the)"
    assert "$(echo "$t" | field 1 | grep '^Audio > Music' | wc -l)" -ge 5
    assert "$(echo "$t" | field 1 | grep '^Other > E-books' | wc -l)" -ge 10
}

test_lt() {
    echo lt standard
    lt lord of the rings >/dev/null

    echo lt date
    assert "$(lt -s date lord of the rings | field 2 | grep -E '\<(ago|last)\>' | wc -l)" -ge 30

    echo lt se
    assert "$(lt -s se lord of the rings | field 4 | grep -E '^[0-9]{3,}$' | wc -l)" -ge 25

    echo lt le
    assert "$(lt -s le lord of the rings | field 5 | grep -E '^[0-9]{3,}$' | wc -l)" -ge 18

    echo lt magnets "(might take some time)"
    assert "$(lt --link-conv the -s se | field 7 | grep '\<magnet:?' | wc -l)" -ge 40

    echo lt latest
    lt 150 --latest >/dev/null
}

test_1337x() {
    echo 1337x standard
    t1337x the >/dev/null

    echo 1337x size
    assert "$(t1337x -s size the | field 3 | grep -E '^[0-9]{3,}(\.[0-9]+)? GB$' | wc -l)" -ge 12
    echo 1337x reverse size
    assert "$(t1337x -s size -r the | field 3 | grep -E '^0(\.[0-9]+)? KB$' | wc -l)" -ge 17

    echo 1337x date
    assert "$(t1337x -s date the | field 2 | grep -E 'am$' | wc -l)" -ge 5
    echo 1337x reverse date
    assert "$(t1337x -s date -r the | field 2 | grep -E " '08$" | wc -l)" -ge 10

    echo 1337x se
    assert "$(t1337x -s se the | field 4 | grep -E '^[0-9]{4,}$' | wc -l)" -ge 15
    echo 1337x reverse se
    assert "$(t1337x -s se -r the | field 4 | grep -Fx '0' | wc -l)" -ge 15

    echo 1337x le
    assert "$(t1337x -s le the | field 5 | grep -E '^[0-9]{4,}$' | wc -l)" -ge 15
    echo 1337x reverse le
    assert "$(t1337x -s le -r the | field 5 | grep -Fx '0' | wc -l)" -ge 15

    echo 1337x magnets "(might take some time)"
    assert "$(t1337x --link-conv the -s se | field 7 | grep '\<magnet:?' | wc -l)" -ge 20

    echo 1337x latest
    t1337x 42 --latest >/dev/null

    echo 1337x categories
    assert "$(t1337x -c games -s se DLC | field 1 | grep '\<FitGirl\>' | wc -l)" -ge 2
}

test_rarbg() {
    echo rarbg standard
    rarbg list >/dev/null

    echo rarbg size
    assert "$(rarbg -s size the | field 4 | grep -E '^[0-9]{3,}(\.[0-9]+)? GB$' | wc -l)" -ge 18
    echo rarbg reverse size
    assert "$(rarbg -s size -r the | field 4 | grep -E '^0(\.[0-9]+)? KB$' | wc -l)" -ge 18

    echo rarbg date
    assert "$(rarbg -s date the | field 3 | grep -E "$(date "+%Y-%m-%d")" | wc -l)" -ge 1
    echo rarbg reverse date
    assert "$(rarbg -s date -r the | field 3 | grep '1970-' | wc -l)" -ge 4

    echo rarbg se
    assert "$(rarbg -s se the | field 5 | grep -E '^[0-9]{3,}$' | wc -l)" -ge 18
    echo rarbg reverse se
    assert "$(rarbg -s se -r the | field 5 | grep -Fx '0' | wc -l)" -ge 18

    echo rarbg le
    assert "$(rarbg -s le the | field 6 | grep -E '^[0-9]{3,}$' | wc -l)" -ge 18
    echo rarbg reverse le
    assert "$(rarbg -s le -r the | field 6 | grep -Fx '0' | wc -l)" -ge 18

    echo rarbg latest
    rarbg 25 --latest >/dev/null

    echo rarbg links
    assert "$(rarbg the -s se | field 7 | grep '\<https://' | wc -l)" -ge 20

    echo rarbg categories
    assert "$(rarbg -c apps -s se the | field 1 | grep -F 'Apps' | wc -l)" -ge 3
}

test_nyaa() {
    echo nyaa standard
    nyaa list >/dev/null

    echo nyaa comments
    assert "$(nyaa -s comments a | field 2 | grep ' Dragon Ball ' | wc -l)" -ge 3
    echo nyaa reverse comments
    nyaa -s comments -r list >/dev/null

    echo nyaa size
    assert "$(nyaa -s size a | field 3 | grep -E '(^[0-9]{3}(\.[0-9]+)? GiB$| TiB$)' | wc -l)" -ge 50
    echo nyaa reverse size
    assert "$(nyaa -s size -r a | field 3 | grep -E '^[0-9]+ Bytes$' | wc -l)" -ge 18

    echo nyaa date
    assert "$(nyaa -s date a | field 4 | grep -E "$(date "+%Y-%m-%d")"| wc -l)" -ge 4
    echo nyaa reverse date
    assert "$(nyaa -s date -r a | field 4 | grep -E '^2008-06-23\>' | wc -l)" -ge 30

    echo nyaa se
    assert "$(nyaa -s se a | field 5 | grep -E '^[0-9]{3,}$' | wc -l)" -ge 40
    echo nyaa reverse se
    assert "$(nyaa -s se -r a | field 5 | grep -Fx '0' | wc -l)" -ge 40

    echo nyaa le
    assert "$(nyaa -s le a | field 6 | grep -E '^[0-9]{3,}$' | wc -l)" -ge 8
    echo nyaa reverse le
    assert "$(nyaa -s le -r a | field 6 | grep -Fx '0' | wc -l)" -ge 40

    echo nyaa downloads
    assert "$(nyaa -s downloads a | field 7 | grep -E '\<[0-9]{5,}\>' | wc -l)" -ge 60
    echo nyaa reverse downloads
    assert "$(nyaa -s downloads -r a | field 7 | grep -E '\<0\>' | wc -l)" -ge 60

    echo nyaa latest
    nyaa --latest >/dev/null

    echo nyaa magnets
    assert "$(nyaa the -s se | field 8 | grep '\<magnet:?' | wc -l)" -ge 75

    echo nyaa categories
    assert "$(nyaa -c live-action-idol-promotional-video -s se a | field 1 | grep -F 'Live Action - Idol/Promotional Video' | wc -l)" -ge 70
}

#libgen should be split into subcommands
test_libgen_nf() {
    echo libgen_nf standard
    libgen_nf name >/dev/null

    echo libgen_nf 100 results
    libgen_nf 100 -R 100 name >/dev/null

    echo libgen_nf size
    assert "$(libgen_nf -s size name | field 3 | grep -E '^[0-9]{,3} Kb' | wc -l)" -ge 20
    echo libgen_nf reverse size
    assert "$(libgen_nf -s size -r name | field 3 | grep -E '^[0-9]{2,} Mb' | wc -l)" -ge 18

    echo libgen_nf reverse pages
    assert "$(libgen_nf  name -s pages -r | field 2 | grep -E '^[0-9]{3,}\>' | wc -l)" -ge 18

    echo libgen_nf extension
    assert "$(libgen_nf  name -s extension | field 6 | grep 'azw3' | wc -l)" -ge 10

    echo libgen_nf search by date
    assert "$(libgen_nf -S date 2025 | field 4 | grep "$(date +%Y)" | wc -l)" -ge 25

    echo libgen_nf search by author
    assert "$(libgen_nf -S author lovecraft | field 5 | grep -i lovecraft | wc -l)" -ge 25

    echo libgen_nf search by lang
    libgen_nf -S lang french >/dev/null

    echo libgen_nf search by publisher
    libgen_nf -S publisher Scholastic >/dev/null

    echo libgen_nf search by tags
    libgen_nf -S tags blood >/dev/null

    echo libgen_nf search by series
    libgen_nf -S series time >/dev/null

    echo libgen_nf search by md5
    libgen_nf 1 -S md5 6F7C9AADD70E6F15531F41505B95E3C6 >/dev/null

    echo libgen_nf search by isbn
    libgen_nf 5 -S isbn 9783540332589 >/dev/null

    echo libgen_nf latest
    libgen_nf --latest >/dev/null

    echo libgen_nf links
    assert "$(libgen_nf --link-conv name | field 7 | grep '\<https://' | wc -l)" -ge 25
}

test_libgen_f() {
    echo libgen_f standard
    libgen_f list >/dev/null

    echo libgen_f search by title
    libgen_f -S title love >/dev/null

    echo libgen_f search by series
    libgen_f -S series blind >/dev/null

    echo libgen_f latest
    libgen_f --latest >/dev/null

    echo libgen_f links
    assert "$(libgen_f --link-conv list | field 6 | grep '\<https://' | wc -l)" -ge 25
}

#this should be rebuild completely
test_libgen_s() {
    echo libgen_s standard
    libgen_s list >/dev/null

    #echo libgen_s latest
    #libgen_s --latest >/dev/null

    echo libgen_s links
    assert "$(libgen_s --link-conv list | field 5 | grep '\<https://' | wc -l)" -ge 25
}

test_tpb
test_lt
test_1337x
test_rarbg
test_nyaa
test_libgen_nf
test_libgen_f
test_libgen_s
