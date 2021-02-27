#!/usr/bin/env bash

# short program to demonstrate how to run a pipeline where two
# different environments process something in sequence

# quit if someting goes wrong
set -eu

# clean up when we exit
trap 'echo cleaning up; rm -r bobos; rm thepipe' EXIT

# add a pipe
mkfifo thepipe

# set the output directory. Note we have to export it: if not it won't
# be imported into the subshells.
export OUTDIR=bobos
mkdir -p $OUTDIR

function addbobo() {
    (
        echo "setting up bobo maker" >&2
        # set up something crazy here
        while read item
        do
            # this could do anything, for now it's just creating a
            # file, but one could imagine creating an output data file
            # in some weird environemnt.

            # simple do something
            outpath=${OUTDIR}/${item}
            echo "making $item" >&2
            echo "hi I'm $item" > $outpath

            # this is the only thing we echo to stdout, so we can pass
            # it to the next process
            echo $outpath
        done
        echo "reached end of addbobo" >&2
    )
}

function readbobo() {
    (
        echo "setting up bobo reader" >&2
        # you can set some other crazy thing up here
        while read item
        do
            echo "reading input $item"
            cat $item
            echo -e "done!\n"
        done
        echo "reached end of readbobo" >&2
    )
}

echo "making pipe"
cat thepipe | addbobo | readbobo &

# now we feed the pipe
echo "loopin"
for num in $(seq 10); do
    echo bobo${num}.txt
    sleep 0.5
done > thepipe

