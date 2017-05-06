#!/bin/sh

# Filter maven output and inject 'travis_fold'/'travis_time' markers
exec awk '
BEGIN {
  attn=0
  id=0
  start=0
  end=0
}
{
  if (attn==1 && match($0, /^\[INFO\] Building /)) {
    if (id>0) {
      if (start>0) {
        "date +%s%N"|getline end
        close("date +%s%N")
        printf "travis_time:end:maven.%d:start=%d,end=%d,duration=%d\n", id, start, end, (end-start)
      }
      printf "travis_fold:end:maven.%d\n", id
    }
    id++
    printf "travis_fold:start:maven.%d\n", id
    "date +%s%N"|getline start
    close("date +%s%N")
    printf "travis_time:start:maven.%d\n", id
  } else if (match($0,/^\[INFO\] -+$/)) {
    attn=1
  } else {
    attn=0
  }
  print
}
END {
  if (id>0) {
    if (start>0) {
      "date +%s%N"|getline end
      close("date +%s%N")
      printf "travis_time:end:maven.%d:start=%d,end=%d,duration=%d\n", id, start, end, (end-start)
    }
    printf "travis_fold:end:maven.%d\n", id
  }
}'
