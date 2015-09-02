clear; close all; clc;

%% TEST
% Assert that the full LASSO model and OLS are equal

n = 100;
p = 25;

X = normalize(rand(n, p));
y = center(rand(n,1));

b_lar = lasso(X,y);
b_ols = X\y;

assert(norm(b_lar(:,end) - b_ols) < 1e-12)

