clear all, close all, clc
figpath = './figures/';
addpath('./utils');
addpath('./DATA');

y0 = [0; .01];
d = 0.02;
a = 1;
b = 5; 
w = .5;
g = 8; 

dt = .001;
tspan = 0:dt:1000;
[t,y] = ode45(@(t,y)duffing(t,y,d,a,b,g,w),tspan,y0);
xdat = y;
stackmax = 100;  % changing the number of shift-stacked rows
rmax = 5;

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
% compute derivative using fourth order central difference
% use TVRegDiff if more error 
dV = zeros(length(V)-5,r);
for i=3:length(V)-3
    for k=1:r
        dV(i,k) = (1/(12*dt))*(-V(i+2,k)+8*V(i+1,k)-8*V(i-1,k)+V(i-2,k));
    end
end  
r=min(rmax,r);

%% CONTINUOUS TIME
x = V(100:199000,1:r);
dx = dV(100:199000,1:r);
Xi = x\dx;
A = Xi(1:r,1:r)';
B = A(1:r-1,r)
A = A(1:r-1,1:r-1)
sys = ss(A,B,eye(r-1),0*B);

%SIMULATE
L = 1:195000;
[y,t] = lsim(sys,x(L,r),dt*(L-1),x(1,1:r-1));

%%
% save ./DATA/FIG04_DUFFINGFORCED.mat