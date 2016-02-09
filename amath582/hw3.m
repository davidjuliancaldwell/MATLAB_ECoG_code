%% AMATH 582 HW 3 - David Caldwell - Save Dereck

%% clear workspace, load in everything

% get a clean workspace
close all;clear all;clc

% change to directory where files are located
cd C:/Users/David/Desktop/Research/RaoLab/MATLAB/Code/amath582

% noisy derek in color
noisyColor = imread('derek1','jpeg');

% noise derek in BW
noiseBW = imread('derek2','jpeg');

% rash derek in color
rashColor = imread('derek3','jpeg');

% rash derek in BW
rashBW = imread('derek4','jpeg');


%% plot the dereks
figure

subplot(2,2,1)
imshow(noisyColor)
title('Derek 1')

subplot(2,2,2)
imshow(noiseBW)
title('Derek 2')

subplot(2,2,3)
imshow(rashColor)
title('Derek 3')

subplot(2,2,4)
imshow(rashBW)
title('Derek 4')

subtitle('Original Noisy and Corrupted Images')
%% make em doubles
noisyColorDouble = double(noisyColor);
noisyBWDouble = double(noiseBW);
rashColorDouble = double(rashColor);
rashBWDouble = double(rashBW);

% NOTE - all three are the same size, 253x361

% localize rash on both color and BW
figure
subplot(1,2,1)
imagesc(double(rgb2gray(rashColor)))
colormap(gray)
set(gca,'Fontsize',[14])
ylabel('Row')
xlabel('Column')
axis([145 195 110 170 ])

title('Rash in Color image, converted to Gray')
subplot(1,2,2)
imagesc(rashBWDouble)
colormap(gray)
set(gca,'Fontsize',[14])
ylabel('Row')
xlabel('Column')
title('Rash in Black and White image')
axis([145 195 110 170])


% try centering around (column = 170-ish, row =  150), index 255 
% range of 140-160 for row, 160-180 for column?
% find linear index of center of rash?

centerLin = sub2ind(size(rashBWDouble),150,170);

% try sub2ind
idx = sub2ind(size(rashBW),[140:160],[160:180]);


%% look at FFTs of them
close all
figure
noisyBWFFT = fft2(noisyBWDouble);
contourf(log(abs(fftshift(noisyBWFFT))+1))
h = colorbar;
xlabel('Ky')
ylabel('Kx')
ylabel(h,'FFT Magnitude')
title('FFT of noisy Derek BW')
set(gca,'Fontsize',[14])

% find center - this doesn't work?
% [max,idMax] = max(abs(dNBWDt(:)));

noisyDoubleRed = noisyColorDouble(:,:,1);
noisyRedFFT = fft2(noisyDoubleRed);

noisyDoubleGreen = noisyColorDouble(:,:,2);
noisyGreenFFT = fft2(noisyDoubleGreen);

noisyDoubleBlue = noisyColorDouble(:,:,3);
noisyBlueFFT = fft2(noisyDoubleBlue);

figure
subplot(3,1,1)
contourf(log(abs(fftshift(noisyRedFFT))+1))
title('Red')
xlabel('Ky')
ylabel('Kx')
h = colorbar
ylabel(h,'FFT Magnitude')
set(gca,'Fontsize',[14])

subplot(3,1,2)
contourf(log(abs(fftshift(noisyGreenFFT))+1))
title('Green')
colorbar
set(gca,'Fontsize',[14])

subplot(3,1,3)
contourf(log(abs(fftshift(noisyBlueFFT))+1))
title('Blue')
colorbar
set(gca,'Fontsize',[14])

subtitle('FFT of RGB Channels of noisy Derek color')

%% filter 1 and 2
[nx,ny] = size(noiseBW);
kx = [1:nx];
ky = [1:ny];
[Kx,Ky] = meshgrid(kx,ky);
sigma = [0.0001 0.0003 0.0005 0.001];
centerX = nx/2 + 1;
centerY = ny/2 + 1;

% plot surface of Gaussian filter
% plot filtered image 

fig1 = figure;
fig2 = figure;
for j = 1:length(sigma)
    filterGauss = exp(-sigma(j)*(Kx-centerX).^2-sigma(j)*(Ky-centerY).^2)';
    filterGaussShift = fftshift(filterGauss);
    figure(fig2)
    subplot(2,2,j)
    surfl(Kx,Ky,filterGauss'), shading interp
    xlabel('Kx')
    ylabel('Ky')
    zlabel('Magnitude of Filtering')
    noisyBWfiltered = filterGaussShift.*noisyBWFFT;
    BWdenoised = ifft2(noisyBWfiltered);
    BWdenoiseUINT8 = uint8(BWdenoised);
    figure(fig1);
    subplot(2,2,j)
    imshow(BWdenoiseUINT8)
end
subtitle('Filtered BW Derek images with various filtering strengths Sigma')

figure
for j = 1:length(sigma)
        filterGauss = exp(-sigma(j)*(Kx-centerX).^2-sigma(j)*(Ky-centerY).^2)';
    filterGaussShift = fftshift(filterGauss);
    redDenoised = filterGaussShift.*noisyRedFFT;
    greenDenoised = filterGaussShift.*noisyGreenFFT;
    blueDenoised = filterGaussShift.*noisyBlueFFT;
    colorDenoise = ifft2(cat(3,redDenoised,greenDenoised,blueDenoised));
    colorDenoisedUINT8 = uint8(colorDenoise);
    subplot(2,2,j)
    imshow(colorDenoisedUINT8)
end
subtitle('Filtered Color Derek Images with various filtering strengths Sigma')

%% filter 3 and 4 
close all
% try BW first - rashBWdouble
% heat

% look at FFT of rash

figure
rashBWFFT = fft2(rashBWDouble);
contourf(log(abs(fftshift(rashBWFFT))+1))
h = colorbar;
xlabel('Kx')
ylabel('Ky')
ylabel(h,'FFT Magnitude')
title('FFT of rash Derek BW')

[nx,ny] = size(noiseBW);
kx = [1:nx];
ky = [1:ny];
[Kx,Ky] = meshgrid(kx,ky);
sigma = [0.0005 0.0003 0.0001 0.00005];

centerX = nx/2 + 1;
centerY = ny/2 + 1;

fig1 = figure;
fig2 = figure;
for j = 1:length(sigma)
    filterGauss = exp(-sigma(j)*(Kx-centerX).^2-sigma(j)*(Ky-centerY).^2)';
    filterGaussShift = fftshift(filterGauss);
    figure(fig2)
    subplot(2,2,j)
    surfl(Kx,Ky,filterGauss'), shading interp
    xlabel('Kx')
    ylabel('Ky')
    zlabel('Magnitude of Filtering')
    rashBWfiltered = filterGaussShift.*rashBWFFT;
    BWdenoised = ifft2(rashBWfiltered);
    BWdenoiseUINT8 = uint8(BWdenoised);
    figure(fig1);
    subplot(2,2,j)
    imshow(BWdenoiseUINT8)
end
subtitle('Filtered BW Derek images with various filtering strengths Sigma')

% heat equation

x = linspace(0,1,nx); dx = x(2) - x(1);
y = linspace(0,1,ny); dy = y(2) - y(1);

% need identity matrix for Kron command

onex = ones(nx,1); oney = ones(ny,1);

% spdiags - sparse diagonal matrix, keeps track of non-zero stuff,
% efficient! 0 is main diagonal - so puts -2's on main diagonal, and then
% ones on -1 and 1 on diags next to middle diagonal 
% DJC edit to only put the ones on the onexMasked and oneY masked of
% interset 
Dx = (spdiags([onex -2*onex onex],[-1 0 1],nx,nx))/dx.^2;
Ix = eye(nx);
Dy = (spdiags([oney -2*oney oney],[-1 0 1],ny,ny))/dy.^2;
Iy = eye(ny);

% try here to make masked ones that are only ones for the values of
% interest for the diffusion
% try changing up limits of diffusion to not make it so sharp 
% original 140:160, 160:180
onexMasked = zeros(nx,1); oneyMasked = zeros(ny,1);
beginX = 140; endX = 160;
beginY = 153; endY = 184;
onexMasked(beginX:endX) = 1; oneyMasked(beginY:endY)=1;

% make Iy, Ix masked, Dx, Dy masked 
IxMasked = zeros(nx);
vx = [beginX:endX];
indsX = sub2ind(size(IxMasked),vx,vx);
IxMasked(indsX) = 1;


IyMasked = zeros(ny);
vy = [beginY:endY];
indsY = sub2ind(size(IyMasked),vy,vy);
IyMasked(indsY) = 1;

DxMasked = (spdiags([onexMasked -2*onexMasked onexMasked],[-1 0 1],nx,nx))/dx.^2;
DyMasked = (spdiags([oneyMasked -2*oneyMasked oneyMasked],[-1 0 1],ny,ny))/dy.^2;

% replace the extra added entries on the diagonals
DxMasked(beginX-1,beginX) = 0;
DxMasked(endX+1,endX) = 0;
DyMasked(beginY-1,beginY) = 0;
DyMasked(endY+1,endY) = 0;

% DxMasked(129,130) = 0;
% DxMasked(171,170) = 0;
% DyMasked(149,150) = 0;
% DyMasked(191,190) = 0;
% 

% boundary conditions? 
DxMasked(beginX,endX) = 1/dx.^2;
DxMasked(endX,beginX) = 1/dx.^2;
DyMasked(beginY,endY) = 1/dy.^2;
DyMasked(endY, beginY) = 1/dy.^2;

% plot sparse matrix 

figure
hold on

subplot(2,2,1)
spy(DxMasked)
axis([beginX-5 endX+5 beginX-5 endX+5])
title('Sparse representation of Dx')
xlabel('Column Index')
ylabel('Row Index')

subplot(2,2,2)
spy(DyMasked)
title('Sparse representation of Dy')
axis([beginY-5 endY+5 beginY-5 endY+5])

subplot(2,2,3)
spy(IxMasked)
title('Sparse representation of Ix')
axis([beginX-5 endX+5 beginX-5 endX+5])

subplot(2,2,4)
spy(IyMasked)
title('Sparse representation of Iy')
axis([beginY-5 endY+5 beginY-5 endY+5])

% make it 2D with KRON!!!!! 


% Laplacian L
% changed to IyMasked, etc. Dx and Dy changed above 
L = kron(Iy,Dx)+kron(Dy,Ix);
figure
spy(L)
title('Sparse representation of Laplacian L')
xlabel('Column Index')
ylabel('Row Index')

% ode solver wants vector, so reshape the matrix
An0 = reshape(rashBWDouble,nx*ny,1);
D = zeros(size(rashBWDouble));

% trying gaussian to make diffusion constant
centerX = 150;
centerY = 170;
sigma = 0.005;
filterGauss = exp(-sigma*(Kx-centerX).^2-sigma*(Ky-centerY).^2)';
D = filterGauss*0.003; 
surfl(Kx,Ky,D)

% linear D 
% D((beginX:endX),(beginY:endY)) = 0.0005;
D = reshape(D,nx*ny,1);


% D = 0.0005;
% 0.003 for D = 0.005 seems like a good start 
tspan = [0 0.008 0.012 0.015];
[t,A_sol] = ode45('image_rhsD',tspan,An0,[],L,D);

figure
for j=1:4
   subplot(2,2,j)
   % reshape into nx by ny image
   Aclean = uint8(reshape(A_sol(j,:),nx,ny));
   imshow(Aclean)
end

%% filter to get rid of boundary condition


centerX = nx/2 + 1;
centerY = ny/2 + 1;

fig1 = figure;
fig2 = figure;
for j = 1:length(sigma)
    filterGauss = exp(-sigma(j)*(Kx-centerX).^2-sigma(j)*(Ky-centerY).^2)';
    filterGaussShift = fftshift(filterGauss);
    figure(fig2)
    subplot(2,2,j)
    surfl(Kx,Ky,filterGauss'), shading interp
    xlabel('Kx')
    ylabel('Ky')
    zlabel('Magnitude of Filtering')
    rashBWfiltered = filterGaussShift.*fft2(double(Aclean));
    BWdenoised = ifft2(rashBWfiltered);
    BWdenoiseUINT8 = uint8(BWdenoised);
    figure(fig1);
    subplot(2,2,j)
    imshow(BWdenoiseUINT8)
end
subtitle('Filtered BW Derek images with various filtering strengths Sigma')

%% do it in color 

% 
rashDoubleRed = rashColorDouble(:,:,1);
rashDoubleGreen = rashColorDouble(:,:,2);
rashDoubleBlue = rashColorDouble(:,:,3);

% ode solver wants vector, so reshape the matrix
D = 0.0005;
% 0.003 for D = 0.005 seems like a good start 
tspan = [0 0.008 0.05 0.1];

% do it for red, green, then recombine

% red

rashR = reshape(rashDoubleRed,nx*ny,1);
[t,rashR_sol] = ode45('image_rhsD',tspan,rashR,[],L,D);

figure
for j=1:4
   subplot(2,2,j)
   % reshape into nx by ny image
   rashRclean = uint8(reshape(rashR_sol(j,:),nx,ny));
   imshow(rashRclean)
end

% green

rashG = reshape(rashDoubleGreen,nx*ny,1);
[t,rashG_sol] = ode45('image_rhsD',tspan,rashG,[],L,D);

figure
for j=1:4
   subplot(2,2,j)
   % reshape into nx by ny image
   rashGclean = uint8(reshape(rashG_sol(j,:),nx,ny));
   imshow(rashGclean)
end

% blue

rashB = reshape(rashDoubleBlue,nx*ny,1);
[t,rashB_sol] = ode45('image_rhsD',tspan,rashB,[],L,D);

figure
for j=1:4
   subplot(2,2,j)
   % reshape into nx by ny image
   rashBclean = uint8(reshape(rashB_sol(j,:),nx,ny));
   imshow(rashBclean)
end

rashClean = cat(3,rashRclean,rashGclean,rashBclean);
figure
imshow(rashClean)

%% filter to get rid of boundary condition


centerX = nx/2 + 1;
centerY = ny/2 + 1;

figure

noisyRedFFT = (fft2(double(rashRclean)));
noisyGreenFFT = (fft2(double(rashGclean)));
noisyBlueFFT = (fft2(double(rashBclean)));

for j = 1:length(sigma)
        filterGauss = exp(-sigma(j)*(Kx-centerX).^2-sigma(j)*(Ky-centerY).^2)';
    filterGaussShift = fftshift(filterGauss);
    redDenoised = filterGaussShift.*noisyRedFFT;
    greenDenoised = filterGaussShift.*noisyGreenFFT;
    blueDenoised = filterGaussShift.*noisyBlueFFT;
    colorDenoise = ifft2(cat(3,redDenoised,greenDenoised,blueDenoised));
    colorDenoisedUINT8 = uint8(colorDenoise);
    subplot(2,2,j)
    imshow(colorDenoisedUINT8)
end
subtitle('Filtered Color Derek Images with various filtering strengths Sigma')


%% try gaussian
[nx,ny] = size(noiseBW);
x = linspace(0,1,nx); dx = x(2) - x(1);
y = linspace(0,1,ny); dy = y(2) - y(1);

% need identity matrix for Kron command


onex = ones(nx,1); oney = ones(ny,1);

% spdiags - sparse diagonal matrix, keeps track of non-zero stuff,
% efficient! 0 is main diagonal - so puts -2's on main diagonal, and then
% ones on -1 and 1 on diags next to middle diagonal 
% DJC edit to only put the ones on the onexMasked and oneY masked of
% interset 
Dx = (spdiags([onex -2*onex onex],[-1 0 1],nx,nx))/dx.^2;
Ix = eye(nx);
Dy = (spdiags([oney -2*oney oney],[-1 0 1],ny,ny))/dy.^2;
Iy = eye(ny);

% filterGauss = exp(-sigma*(Kx-centerX).^2-sigma(j)*(Ky-centerY).^2)';


L = kron(Iy,Dx)+kron(Dy,Ix);
figure
spy(L)
title('Sparse representation of Iy')

% take parts of the laplacian that 

% % multiply kron by gaussian?, using centerLin
% lx = [
% ly 
% filterGauss = exp(-sigma*(Kx-centerX).^2-sigma(j)*(Ky-centerY).^2)';

% ode solver wants vector, so reshape the matrix
An0 = reshape(rashBWDouble,nx*ny,1);
D = 0.005;
% 0.003 for D = 0.005 seems like a good start 
tspan = [0 0.004 0.008 0.016];
[t,A_sol] = ode45('image_rhsD',tspan,An0,[],L,D);

figure
for j=1:4
   subplot(2,2,j)
   % reshape into nx by ny image
   Aclean = uint8(reshape(A_sol(j,:),nx,ny));
   imshow(Aclean)
end

%% extract part of matrix, run diffusion on it
close all
noiseSmall = noisyBWDouble([140:160],[160:180]);
[nx,ny] = size(noiseSmall);
x = linspace(0,1,nx); dx = x(2) - x(1);
y = linspace(0,1,ny); dy = y(2) - y(1);

% need identity matrix for Kron command


onex = ones(nx,1); oney = ones(ny,1);

onex = ones(nx,1); oney = ones(ny,1);

% spdiags - sparse diagonal matrix, keeps track of non-zero stuff,
% efficient! 0 is main diagonal - so puts -2's on main diagonal, and then
% ones on -1 and 1 on diags next to middle diagonal 
% DJC edit to only put the ones on the onexMasked and oneY masked of
% interset 
Dx = (spdiags([onex -2*onex onex],[-1 0 1],nx,nx))/dx.^2;
Ix = eye(nx);
Dy = (spdiags([oney -2*oney oney],[-1 0 1],ny,ny))/dy.^2;
Iy = eye(ny);
Dx(1,nx) = 1;
Dx(nx,1) = 1;
Dy(1,ny) = 1;
Dy(ny,1) = 1;

% filterGauss = exp(-sigma*(Kx-centerX).^2-sigma(j)*(Ky-centerY).^2)';


L = kron(Iy,Dx)+kron(Dy,Ix);
figure
spy(L)
title('Sparse representation of Laplacian')

% take parts of the laplacian that 

% % multiply kron by gaussian?, using centerLin
% lx = [
% ly 
% filterGauss = exp(-sigma*(Kx-centerX).^2-sigma(j)*(Ky-centerY).^2)';

% ode solver wants vector, so reshape the matrix
An0 = reshape(noiseSmall,nx*ny,1);
D = 0.1;
% 0.003 for D = 0.005 seems like a good start 
tspan = [0 0.003 0.004 0.5];
[t,A_sol] = ode45('image_rhsD',tspan,An0,[],L,D);

figure
for j=1:4
   subplot(2,2,j)
   % reshape into nx by ny image
   Aclean = uint8(reshape(A_sol(j,:),nx,ny));
   imshow(Aclean)
end

%% filter to get rid of boundary condition


centerX = nx/2 + 1;
centerY = ny/2 + 1;
kx = [1:nx];
ky = [1:ny];
[Kx,Ky] = meshgrid(kx,ky);
sigma = [0.0001 0.0003 0.003 0.005];

fig1 = figure;
fig2 = figure;
for j = 1:length(sigma)
    filterGauss = exp(-sigma(j)*(Kx-centerX).^2-sigma(j)*(Ky-centerY).^2)';
    filterGaussShift = fftshift(filterGauss);
    figure(fig2)
    subplot(2,2,j)
    surfl(Kx,Ky,filterGauss'), shading interp
    xlabel('Kx')
    ylabel('Ky')
    zlabel('Magnitude of Filtering')
    rashBWfiltered = filterGaussShift.*fft2(double(Aclean));
    BWdenoised = ifft2(rashBWfiltered);
    BWdenoiseUINT8 = uint8(BWdenoised);
    figure(fig1);
    subplot(2,2,j)
    imshow(BWdenoiseUINT8)
end
subtitle('Filtered BW Derek images with various filtering strengths Sigma')

