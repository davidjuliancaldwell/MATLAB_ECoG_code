function dy = duffing(t,y,d,a,b,g,w)
% Copyright 2016, All Rights Reserved
% Code by Steven L. Brunton

dy = [
y(2);
-d*y(2) - a*y(1) - b*y(1)^3 + g*cos(w*t);
];



