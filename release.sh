#!/bin/bash -v

for m in tarpit slf4j logback jetty jetty-jsp httpclient-3 httpclient-4 commons-codec commons-dbcp commons-dbutils commons-pool; do
    echo $m
    ( cd $m && jrake $@ )
done
