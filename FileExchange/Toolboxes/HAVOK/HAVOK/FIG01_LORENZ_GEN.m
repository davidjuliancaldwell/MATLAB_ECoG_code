% Copyright 2016, All Rights Reserved
% Code by Steven L. Brunton
clear all, close all, clc
figpath = './figures/';
addpath('./utils');

% generate Data
sigma = 10;  % Lorenz's parameters (chaotic)
beta = 8/3;
rho = 28;
n = 3;
x0=[-8; 8; 27];  % Initial condition

% Integrate
dt = 0.001;
tspan=[dt:dt:200];
N = length(tspan);
options = odeset('RelTol',1e-12,'AbsTol',1e-12*ones(1,n));
[t,xdat]=ode45(@(t,x) lorenz(t,x,sigma,beta,rho),tspan,x0,options);

stackmax = 100;  % the number of shift-stacked rows
lambda = 0;   % threshold for sparse regression (use 0.02 to kill terms)
rmax = 15;       % maximum singular vectors to include

%% EIGEN-TIME DELAY COORDINATES
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

%% COMPUTE DERIVATIVES
% compute derivative using fourth order central difference
% use TVRegDiff if more error 
dV = zeros(length(V)-5,r);
for i=3:length(V)-3
    for k=1:r
        dV(i-2,k) = (1/(12*dt))*(-V(i+2,k)+8*V(i+1,k)-8*V(i-1,k)+V(i-2,k));
    end
end  
% concatenate
x = V(3:end-3,1:r);
dx = dV;

%%  BUILD HAVOK REGRESSION MODEL ON TIME DELAY COORDINATES
% This implementation uses the SINDY code, but least-squares works too
% Build library of nonlinear time series
polyorder = 1;
Theta = poolData(x,r,1,0);
% normalize columns of Theta (required in new time-delay coords)
for k=1:size(Theta,2)
    normTheta(k) = norm(Theta(:,k));
    Theta(:,k) = Theta(:,k)/normTheta(k);
end 
m = size(Theta,2);
% compute Sparse regression: sequential least squares
% requires different lambda parameters for each column
clear Xi
for k=1:r-1
    Xi(:,k) = sparsifyDynamics(Theta,dx(:,k),lambda*k,1);  % lambda = 0 gives better results 
end
Theta = poolData(x,r,1,0);
for k=1:length(Xi)
    Xi(k,:) = Xi(k,:)/normTheta(k);
end
A = Xi(2:r+1,1:r-1)';
B = A(:,r);
A = A(:,1:r-1);
%
L = 1:50000;
sys = ss(A,B,eye(r-1),0*B);
[y,t] = lsim(sys,x(L,r),dt*(L-1),x(1,1:r-1));

%% SAVE DATA (OPTIONAL)
% save ./DATA/FIG01_LORENZ.mat