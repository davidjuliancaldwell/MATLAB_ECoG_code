clear all, close all, clc
figpath = './figures/';
addpath('./utils');
T = readtable('./DATA/nycmeas.dat','Delimiter','space');

X = T.x609;
tc = 1:length(X);
dt = .1;
tf = 1:dt:length(X);
X = interp1(tc,X,tf,'spline')';
xdat = X;
stackmax = 50;  % number of shift-stacked rows
rmax = 9;

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

%% DISCRETE TIME
x = V(1:end-1,1:r);
xprime = V(2:end,1:r);

Xi = xprime\x;
B = Xi(1:r-1,r);
A = Xi(1:r-1,1:r-1);
sys = ss(A,B,eye(r-1),0*B,dt);

L = 1:length(x);
[y,t] = lsim(sys,x(L,r),dt*(L-1),x(1,1:r-1));

% save ./DATA/FIG09_MEASLESNYC.mat