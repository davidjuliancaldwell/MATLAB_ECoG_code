% Copyright 2016, All Rights Reserved
% Code by Steven L. Brunton
clear all, close all, clc
figpath = './figures/';
addpath('./utils');

% generate Data
a = .1;  
b = .1;
c = 14;
n = 3;
x0=[1; 1; 1];  % Initial condition

% Integrate
dt = 0.001;
tspan=[dt:dt:500];
N = length(tspan);
options = odeset('RelTol',1e-12,'AbsTol',1e-12*ones(1,n));
[t,xdat]=ode45(@(t,x) rossler(t,x,a,b,c),tspan,x0,options);

stackmax = 100;  % the number of shift-stacked rows
rmax = 6;  % maximum number of singular values

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
x = V(1:end-1,1:r);
xprime = V(2:end,1:r);

Xi = xprime\x;
B = Xi(1:r-1,r)
A = Xi(1:r-1,1:r-1)
sys = ss(A,B,eye(r-1),0*B,dt);

% SIMULATE
L = 1:149000;
[y,t] = lsim(sys,x(L,r),dt*(L-1),x(1,1:r-1));

% save ./DATA/FIG02_ROSSLER.mat