#!/bin/bash
#================================================================
# HEADER
#================================================================
# [Antonio Franco] stack_and_audio
#  Usage: ./stack_and_audio.sh first.gif second.gif audio.mp3
# Script that given two gifs and one audio file creates an
# mp4 video with the two gifs vertically stacked and the
# mp3 track as main audio track.
# The output file has the name of the first gif with the mp4
# extension. It scales everything to the width of the first
# gif.
# Since it calculates the duration of the final video as 
# the shortest between the least common multiplier of the
# duration of the two gifs and the audio track, it could
# result in a quite big output file.
#================================================================
# END_OF_HEADER
#================================================================
#	Copyright (C) 2019  Antonio Franco (antonio_franco@live.it)
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <http://www.gnu.org/licenses/>.
#================================================================

SCRIPT_HEADSIZE=$(head -200 ${0} |grep -n "^# END_OF_HEADER" | cut -f1 -d:)

if [ $# -ne 3 ] ; then
    RAWHEAD=$(head -${SCRIPT_HEADSIZE:-99} ${0})
    MYHEAD=$(echo -e $RAWHEAD | tr \# \\n)
    printf "${MYHEAD}"
    exit 1;
fi

#Checks requirements
type ffmpeg >/dev/null 2>&1 || { echo >&2 "ffmpeg required but not installed.  Aborting."; exit 1; }
type exiftool >/dev/null 2>&1 || { echo >&2 "exiftool required but not installed.  Aborting."; exit 1; }

#Euclid's algorithm to find the gcd
my_gcd () {
  a=$1
  b=$2
  while [ $b -ne 0 ]; do
	  remainder=$(( $a % $b ))
	  a=$b
	  b=$remainder
  done
  echo "$a"
}

#lcm
my_lcm(){ 
  c=$1
  d=$2
  g=$(my_gcd $c $d)
  echo "scale=2; $1 * $2 / $g" | bc
}

#Creates a temporary directory
f=$(mktemp -d /tmp/stack_and_audio.XXXXXXXXX)

#Takes the width of the first gif
WID=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 $1)

#Takes the least common multiple of the two durations
DUR1=$(exiftool -Duration $1 | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
DUR1=$(printf %d $(echo "scale=2; $DUR1 * 1000" | bc))

DUR2=$(exiftool -Duration $2 | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
DUR2=$(printf %d $(echo "scale=2; $DUR2 * 1000" | bc))

DUR=$(my_lcm $DUR1 $DUR2)
DUR=$(echo "scale=2; $DUR / 1000" | bc)

#Gif to mp4
ffmpeg -ignore_loop 0 -i $1 -c:v libx264 -pix_fmt yuv420p -crf 4 -b:v 300K -vf scale=$WID:-1 -t $DUR -movflags +faststart $f"/temp-${1/.gif/.mp4}"
ffmpeg -ignore_loop 0 -i $2 -c:v libx264 -pix_fmt yuv420p -crf 4 -b:v 300K -vf scale=$WID:-1 -t $DUR -movflags +faststart $f"/temp-${2/.gif/.mp4}"

#Scale second mp4
ffmpeg -i $f"/temp-${2/.gif/.mp4}" -filter:v scale=$WID":trunc(ow/a/2)*2" -c:a copy $f"/temp-scaled-${2/.gif/.mp4}"

#Stack the twos
ffmpeg -i $f"/temp-${1/.gif/.mp4}" -i $f"/temp-scaled-${2/.gif/.mp4}" -filter_complex vstack=inputs=2 $f"/temp-stack-${1/.gif/.mp4}"

#Change audio track
ffmpeg -i $f"/temp-stack-${1/.gif/.mp4}" -i $3 -c:v copy -map 0:v:0 -map 1:a:0 -shortest "${1/.gif/.mp4}"

#Housekeeping
rm $f"/temp-${1/.gif/.mp4}"
rm $f"/temp-${2/.gif/.mp4}"
rm $f"/temp-scaled-${2/.gif/.mp4}"
rm $f"/temp-stack-${1/.gif/.mp4}"
