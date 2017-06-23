% Copyright 2016, All Rights Reserved
% Code by Steven L. Brunton

% THIS CODE USES SDETools by Andrew D. Horchler, adh9@case.edu 
% see README in utils/SDETools-master

clear all, close all, clc
figpath = './figures/';
addpath('./utils');
addpath('./DATA');

A0 = .1;
tspan = 0:.1:100;
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
f = @(t,A)[mu*A + nu*conj(A) + B1*A^3 + B2*A^2*conj(A) + B3*A*conj(A)^2 + B4*conj(A)^3];
g = @(t,A)[(b1 + sqrt(-1)*b3)*real(A) + (b2 + sqrt(-1)*b4)*imag(A)];
opts = sdeset('RandSeed',19);
dt2 = 0.1;
t2 = 0:dt2:100000;
y = sde_euler(f,g,t2,A0,opts);
xdat2 = real(y);
%% AVERAGE DATA OVER A FEW DT's
clear t
clear xdat
stackmax = 100;  % changing the number of shift-stacked rows
rmax = 4;
avgwin = 10;
for k=1:floor(length(t2)/avgwin)
    xdat(k) = mean(xdat2((k-1)*avgwin+1:k*avgwin));
    t(k)  = mean(t2((k-1)*avgwin+1:k*avgwin));
end
xdat = xdat';
tspan = t;
dt = dt2*avgwin;

%% COMPUTE EIGEN TIME SERIES
clear V, clear dV, clear H
H = zeros(stackmax,size(xdat,1)-stackmax);
for k=1:stackmax
    H(k,:) = xdat(k:end-stackmax-1+k,1);
end
[U,S,V] = svd(H,'econ');
sigs = diag(S);
beta = size(H,1)/size(H,2);
thresh = optimal_SVHT_coef(beta,0) * median(sigs);
r = length(sigs(sigs>thresh))
r=min(rmax,r)

%% DISCRETE TIME
r = 4
x = V(1:end-1,1:r);
xprime = V(2:end,1:r);

Xi = xprime\x;
B = Xi(1:r-1,r);
A = Xi(1:r-1,1:r-1);
sys = ss(A,B,eye(r-1),0*B,dt);

L = 1:20000;
[y,t] = lsim(sys,x(L,r),dt*(L-1),x(1,1:r-1));

% save ./DATA/FIG06_MHD.mat