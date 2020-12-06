include "globals.mzn";

int: width; % paper width
int: height; % paper height
int: blobs_count; % how many blobs

set of int: BLOBS_ARRAY = 1..blobs_count;
array[BLOBS_ARRAY, 1..2] of int: blobs;

% variables: array composed by pairs of (x, y) coordinates which are the starting point of the respective blobs in blobs array. 
% This is a variable so it is not itialized yet, is what we have to find.

array[BLOBS_ARRAY, 1..2] of var int: xy_coord;


% constraint for ensure that the domain of the origins should be [0, width[ and [0, height[
constraint forall(i in BLOBS_ARRAY)
                    ((xy_coord[i,1] >= 0 /\ xy_coord[i,1] < width) /\
                    (xy_coord[i,2] >= 0 /\ xy_coord[i,2] < height));

% non overlap constraint - no GB
%constraint forall(b1, b2 in BLOBS_ARRAY where b1 < b2) (
%                    (xy_coord[b1,1] + blobs[b1,1] <= xy_coord[b2,1]) \/
%                    (xy_coord[b2,1] + blobs[b2,1] <= xy_coord[b1,1]) \/
%                    (xy_coord[b1,2] + blobs[b1,2] <= xy_coord[b2,2]) \/
%                    (xy_coord[b2,2] + blobs[b2,2] <= xy_coord[b1,2]));
                    

% non-overlap constraint using global constrint
constraint diffn(xy_coord[..,1],xy_coord[..,2], blobs[..,1], blobs[..,2]);

% each piece must fit in the paper roll
constraint forall(i in BLOBS_ARRAY)
                  (((blobs[i,1] + xy_coord[i,1]) <= width) /\ ((blobs[i,2] + xy_coord[i,2]) <= height));

% implied cumulative constraints 
constraint cumulative(xy_coord[..,1], blobs[..,1], blobs[..,2], height);
constraint cumulative(xy_coord[..,2], blobs[..,2], blobs[..,1], width);
  
% this constraint forces the first blob to cut to be placed into bottom-left quadrant of the box
constraint (xy_coord[1,1] <= (width/2 - blobs[1,1]/2)) /\ (xy_coord[1,2] <= (height/2 - blobs[1,2] / 2));


% search
ann:search_strategy;
search_strategy = int_search(xy_coord, first_fail, indomain_split);
%search_strategy = int_search(xy_coord, dom_w_deg, indomain_split);
%search_strategy = int_search(xy_coord, most_constrained, indomain_split);
solve :: search_strategy satisfy;
