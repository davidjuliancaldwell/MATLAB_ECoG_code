function dy = MackeyGlass(t,y,ytau,gamma,beta,n)
% Copyright 2016, All Rights Reserved
% Code by Steven L. Brunton

dy = beta*(ytau/(1+ytau^n)) - gamma*y;