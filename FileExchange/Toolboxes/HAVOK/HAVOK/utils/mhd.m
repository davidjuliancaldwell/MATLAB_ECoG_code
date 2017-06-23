function dA = mhd(t,A)
% Copyright 2016, All Rights Reserved
% Code by Steven L. Brunton

mu = 1;
nu = 0;
B1 = -.4605*sqrt(-1);
B2 = -1 + .12*sqrt(-1);
B3 = .4395*sqrt(-1);
B4 = -.06 - .12*sqrt(-1);
b1 = .25;
b2 = .07;
b3 = .07;
b4 = .25;
xi1 = 5*randn();
xi2 = 5*randn();
xi3 = 5*randn();
xi4 = 5*randn();

Abar = conj(A);
ReA = real(A);
ImA = imag(A);
f = (b1*xi1 + sqrt(-1)*b3*xi3)*ReA + (b2*xi2 + sqrt(-1)*b4*xi4)*ImA;

dA = [
    mu*A + nu*Abar + B1*A^3 + B2*A^2*Abar + B3*A*Abar^2 + B4*Abar^3 + f
];