include "globals.mzn";

int: width; % paper width
int: height; % paper height
int: blobs_count; % how many blobs
set of int: NPIECES = 1..blobs_count;

set of int: BLOBS_ARRAY = 1..blobs_count;
array[BLOBS_ARRAY, 1..2] of int: blobs; % defns

% variables
array[BLOBS_ARRAY, 1..2] of var int: origin;


% origins domain constraints 
constraint forall(i in BLOBS_ARRAY)
                    ((origin[i,1] >= 0 /\ origin[i,1] < width) /\ (origin[i,2] >= 0 /\ origin[i,2] < height));

% non-overlap constraint
constraint diffn(origin[..,1],origin[..,2], blobs[..,1], blobs[..,2]);


% each piece must fit in the paper roll
constraint forall(i in BLOBS_ARRAY)
                  (((blobs[i,1] + origin[i,1]) <= width) /\ ((blobs[i,2] + origin[i,2]) <= height));

% search
ann:search_ann;
search_ann = int_search(origin, first_fail, indomain_split);
solve :: search_ann satisfy;

output ["width = \(width);\n height = \(height);\n blobs_count = \(blobs_count)\n blobs= \(origin);\n"];