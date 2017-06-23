function dy = rossler(t,y,a,b,c)
% Copyright 2016, All Rights Reserved
% Code by Steven L. Brunton


dy = [
    -y(2) - y(3);
    y(1) + a*y(2);
    b + y(3)*(y(1)-c);
];

