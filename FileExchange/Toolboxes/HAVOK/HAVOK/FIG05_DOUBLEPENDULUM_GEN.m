% Copyright 2016, All Rights Reserved
% Code by Steven L. Brunton
clear all, close all, clc
figpath = './figures/';
addpath('./utils');

load ../DATA/doublependulum.dat

% Integrate
dt = 0.001;

stackmax = 100;  % changing the number of shift-stacked rows
rmax = 5;
tspan = dt:dt:length(xdat);
xdat = sin(traj(:,2));  % nonlinear measurement!!
%% make a movie of the attractor when i increase shift-stack number
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
% compute derivative using fourth order central difference
% use TVRegDiff if more error 
dV = zeros(length(V)-5,r);
for i=3:length(V)-3
    for k=1:r
        dV(i-2,k) = (1/(12*dt))*(-V(i+2,k)+8*V(i+1,k)-8*V(i-1,k)+V(i-2,k));
    end
end  

%% DISCRETE TIME
% concatenate
r = 5
x = V(1:end-1,1:r);
xprime = V(2:end,1:r);

Xi = xprime\x;
B = Xi(1:r-1,r)
A = Xi(1:r-1,1:r-1)
sys = ss(A,B,eye(r-1),0*B,dt);


% SIMULATE
L = 1:50000;
[y,t] = lsim(sys,x(L,r),dt*(L-1),x(1,1:r-1));

% save ./DATA/FIG05_DOUBLEPENDULUM.mat