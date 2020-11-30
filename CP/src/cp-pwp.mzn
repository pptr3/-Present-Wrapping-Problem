include "globals.mzn";

int: width; % paper width
int: height; % paper height
int: blobs_count; % how many blobs

set of int: BLOBS_ARRAY = 1..blobs_count;
array[BLOBS_ARRAY, 1..2] of int: blobs;

% rotation var
array[BLOBS_ARRAY] of var 0..width: width_rot;
array[BLOBS_ARRAY] of var 0..height: height_rot;

% variables: array composed by pairs of (x, y) coordinates which are the starting point of the respective blobs in blobs array. 
% This is a variable so it is not itialized yet, is what we have to find.

array[BLOBS_ARRAY, 1..2] of var int: origin;


% constraint for ensure that the domain of the origins should be [0, width[ and [0, height[
constraint forall(i in BLOBS_ARRAY)
                    ((origin[i,1] >= 0 /\ origin[i,1] < width) /\
                    (origin[i,2] >= 0 /\ origin[i,2] < height));

% non overlap constraint - no GB
%constraint forall(b1, b2 in BLOBS_ARRAY where b1 < b2) (
%                    (origin[b1,1] + blobs[b1,1] <= origin[b2,1]) \/
%                    (origin[b2,1] + blobs[b2,1] <= origin[b1,1]) \/
%                    (origin[b1,2] + blobs[b1,2] <= origin[b2,2]) \/
%                    (origin[b2,2] + blobs[b2,2] <= origin[b1,2]));
                    

% non-overlap constraint using global constrint
constraint diffn(origin[..,1],origin[..,2], blobs[..,1], blobs[..,2]);

% each piece must fit in the paper roll
constraint forall(i in BLOBS_ARRAY)
                  (((blobs[i,1] + origin[i,1]) <= width) /\ ((blobs[i,2] + origin[i,2]) <= height));

% implied cumulative constraints 
constraint cumulative(origin[..,1], blobs[..,1], blobs[..,2], height);
constraint cumulative(origin[..,2], blobs[..,2], blobs[..,1], width);
  
% this constraint forces the first blob to cut to be placed into bottom-left quadrant of the box
constraint (origin[1,1] <= (width/2 - blobs[1,1]/2)) /\ (origin[1,2] <= (height/2 - blobs[1,2] / 2));


% identical rectangle constraint punto 6
constraint
  forall(i in BLOBS_ARRAY)(
    if(blobs[i, 1] == blobs[i + 1, 1] /\ blobs[i, 2] == blobs[i + 1, 2]) then (
      (origin[i, 1] < origin[i + 1, 1]) \/ ((origin[i, 1] == origin[i + 1, 1]) /\ (origin[i, 2] < origin[i + 1, 2]))
   )
    endif
   );
   
% rotation dealing punto 5
constraint
  forall (i in BLOBS_ARRAY)
    ((width_rot[i] == blobs[i,1] /\ height_rot[i] == blobs[i,2]) \/ (width_rot[i] == blobs[i,2] /\ height_rot[i] == blobs[i,1]));

% search
ann:search_strategy;
search_strategy = int_search(origin, first_fail, indomain_split);
%search_strategy = int_search(origin, dom_w_deg, indomain_split);
%search_strategy = int_search(origin, most_constrained, indomain_split);
solve :: search_strategy satisfy;
