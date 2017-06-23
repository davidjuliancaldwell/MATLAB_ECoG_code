clear all, close all, clc
figpath = './figures/';
addpath('./utils');

gamma = 1;
beta = 2;
tau = 2;
n = 9.65;

% Integrate
dt = .001;
tspan = [0:dt:100];
options = ddeset('MaxStep',dt);
sol=dde23(@(t,y,ytau) MackeyGlass(t,y,ytau,gamma,beta,n),2,.5,tspan,options);
t = sol.x;
xdat = (sol.y)';
xdat = interp1(t,xdat,tspan,'spline');
xdat = xdat';

stackmax = 100;  % changing the number of shift-stacked rows
rmax = 4;

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

%% DISCRETE TIME
r = 4;
x = V(1:end-1,1:r);
xprime = V(2:end,1:r);

Xi = xprime\x;
B = Xi(1:r-1,r)
A = Xi(1:r-1,1:r-1)
sys = ss(A,B,eye(r-1),0*B,dt);

%SIMULATE
L = 1:49000;
[y,t] = lsim(sys,x(L,r),dt*(L-1),x(1,1:r-1));

% save ./DATA/FIG03_MACKEYGLASS.mat