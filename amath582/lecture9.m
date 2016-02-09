%% 1-27-2016 - AMATH 582 Lecture 9 
clear all;close all;clc

A = imread('cap','jpeg');
A2 = imresize(A,[600 800]);

Abw = double(rgb2gray(A2));

At = fft2(Abw);
noise = 50000;
Atn = At + noise*(randn(600,800)+i*randn(600,800));

An = ifft2(Atn);
An2 = uint8(An);

imshow(An2)

% heat
[nx,ny] = size(Abw);
x = linspace(0,1,nx); dx = x(2) - x(1);
y = linspace(0,1,ny); dy = y(2) - y(1);

% need identity matrix for Kron command 
onex = ones(nx,1); oney = ones(ny,1);

% spdiags - sparse diagonal matrix, keeps track of non-zero stuff,
% efficient! 0 is main diagonal - so puts -2's on main diagonal, and then
% ones on -1 and 1 on diags next to middle diagonal 
Dx = (spdiags([onex -2*onex onex],[-1 0 1],nx,nx))/dx.^2;
Ix = eye(nx);
Dy = (spdiags([oney -2*oney oney],[-1 0 1],ny,ny))/dy.^2;
Iy = eye(ny);


spy(Dx) % shows whats up, could make periodic by adding 1's on edges?

% make it 2D with KRON!!!!! 

% Laplacian L
L = kron(Iy,Dx)+kron(Dy,Ix);
figure
spy(L)

% ode solver wants vector, so reshape the matrix
An0 = reshape(An,nx*ny,1);
tspan = [0 0.0001 0.0002 0.003];
[t,A_sol] = ode45('image_rhs',tspan,An0,[],L);

for j=1:4
   subplot(2,2,j)
   % reshape into nx by ny image
   Aclean = uint8(reshape(A_sol(j,:),nx,ny));
   imshow(Aclean)
end
