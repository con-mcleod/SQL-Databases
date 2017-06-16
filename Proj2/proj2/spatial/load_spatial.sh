#!/bin/sh

# load.sh  ... A script to load data

dropdb spatial
createdb spatial

# Load the spatial dataset.
# The spatial dataset contains a set of 2 dimensional points.
# This script will create a table named spatial0(x: integer, y: integer),
# and populate it with the spatial dataset.

psql spatial << EOF
drop table if exists small;
create table small ( \
        x Integer, \
        y Integer \
);

\copy small FROM 'small.txt' DELIMITER ',' CSV; 

drop table if exists large;
create table large ( \
        x Integer, \
        y Integer \
);

\copy large FROM 'large.txt' DELIMITER ',' CSV; 

EOF

