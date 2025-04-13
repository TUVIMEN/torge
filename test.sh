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
    torge_source 7 rarbg 20 "$@"
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

    tpb --latest >/dev/null

    echo tpb categories
    local t="$(tpb -c audio,other -s se the)"
    assert "$(echo "$t" | field 1 | grep '^Audio > Music' | wc -l)" -ge 5
    assert "$(echo "$t" | field 1 | grep '^Other > E-books' | wc -l)" -ge 10
}

test_tpb
