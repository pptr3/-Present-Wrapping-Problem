include "globals.mzn";

int: W; % paper width
int: H; % paper height
int: N; % how many blobs

set of int: ARRAY_LENGTH = 1..N;

array[ARRAY_LENGTH] of int: s1;
array[ARRAY_LENGTH] of int: s2;

int: min_x; % min value among s1
int: min_y; % min value among s2

% var
array[ARRAY_LENGTH] of var 0..W-min_x: x;
array[ARRAY_LENGTH] of var 0..W-min_y: y;

% constraints
constraint forall(i in ARRAY_LENGTH) (x[i] + s1[i] <= W);
constraint forall(i in ARRAY_LENGTH) (y[i] + s2[i] <= H);

constraint diffn(x, y, s1, s2);

constraint cumulative(x, s1, s2, H);
constraint cumulative(y, s2, s1, W);

constraint (x[1]<=(W/2 - s1[1]/2)/\ y[1]<=(H/2 - s2[1]/2));


% search
% search
ann:search_ann;
search_ann = int_search(x, input_order, indomain_min);

solve :: search_ann satisfy;

output ["w = \(W);\n h = \(H);\n s1 = \(s1)\n s2= \(s2);\n min_x= \(min_x);\n min_y= \(min_y);\n"];