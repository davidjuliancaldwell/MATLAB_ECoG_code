%% AMATH 582 HW 3 - David Caldwell - Save Derek

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

%% look at FFTs of the noisy/corrupted images

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

%% filter the noisy images with Gaussian filter
close all
[nx,ny] = size(noiseBW);
kx = [1:nx];
ky = [1:ny];

% meshgrid to create Gaussian
[Kx,Ky] = meshgrid(kx,ky);

% filter strengths
sigma = [0.0003 0.0005 0.001 0.005];

% find center of frequency content
noisyBWFFTshift = fftshift(noisyBWFFT);
[maximum,idMax] = max(abs(noisyBWFFTshift(:)));
[centerX,centerY] = ind2sub(size(noisyBWFFT),idMax);

% plot surface of Gaussian filter
% plot filtered image
% below is for Grayscale

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
    zlabel('Magnitude')
    title(['Sigma = ' num2str(sigma(j))])
    set(gca,'Fontsize',[14])
    noisyBWfiltered = filterGaussShift.*noisyBWFFT;
    BWdenoised = ifft2(noisyBWfiltered);
    BWdenoiseUINT8 = uint8(BWdenoised);
    figure(fig1);
    subplot(2,2,j)
    imshow(BWdenoiseUINT8)
    title(['Gaussian with Sigma = ' num2str(sigma(j))]);
    if j == 3
       bwFiltFinal = BWdenoiseUINT8; 
       bwFreqFinal = noisyBWfiltered;
    end
end
subtitle('Filtered BW Derek images with various filtering strengths')
figure(fig2)
subtitle('Gaussian Filters')

% below is for color 

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
    title(['Gaussian with Sigma = ' num2str(sigma(j))]);
    if j == 3
       colorFiltFinal = colorDenoisedUINT8; 
       colorFreqFinalRed = redDenoised;
       colorFreqFinalGreen = greenDenoised;
       colorFreqFinalBlue = blueDenoised;
    end
end
subtitle('Filtered Color Derek Images with various filtering strengths')

% plot final images

figure
imshow(bwFiltFinal)
title('Filtered Grayscale Image with Sigma = 0.001')

figure
imshow(colorFiltFinal)
title('Filtered Color Image with Sigma = 0.001')

% plot FFTs of final images 

figure

contourf(log(abs(fftshift(bwFreqFinal))+1))
h = colorbar;
xlabel('Ky')
ylabel('Kx')
ylabel(h,'FFT Magnitude')
title('FFT of filtered BW image')
set(gca,'Fontsize',[14])

figure
subplot(3,1,1)
contourf(log(abs(fftshift(colorFreqFinalRed))+1))
title('Red')
xlabel('Ky')
ylabel('Kx')
h = colorbar
ylabel(h,'FFT Magnitude')
set(gca,'Fontsize',[14])

subplot(3,1,2)
contourf(log(abs(fftshift(colorFreqFinalGreen))+1))
title('Green')
colorbar
set(gca,'Fontsize',[14])

subplot(3,1,3)
contourf(log(abs(fftshift(colorFreqFinalBlue))+1))
title('Blue')
colorbar
set(gca,'Fontsize',[14])

subtitle('FFT of RGB Channels of filtered Color Image')

%% heat equation, diffusion, to remove rash locally 

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
Dx(1,end) = 1/dx.^2;
Dx(end,1) = 1/dx.^2;

Ix = eye(nx);

Dy = (spdiags([oney -2*oney oney],[-1 0 1],ny,ny))/dy.^2;
Dy(1,end) = 1/dy.^2;
Dy(end,1) = 1/dy.^2;
Iy = eye(ny);

% plot sparse matrix

figure
hold on

subplot(2,2,1)
spy(Dx)

title('Sparse representation of Dx')
xlabel('Column Index')
ylabel('Row Index')

subplot(2,2,2)
spy(Dy)
title('Sparse representation of Dy')

subplot(2,2,3)
spy(Ix)
title('Sparse representation of Ix')

subplot(2,2,4)
spy(Iy)
title('Sparse representation of Iy')

% make it 2D with KRON!!!!!

% Laplacian L
L = kron(Iy,Dx)+kron(Dy,Ix);
figure
spy(L)
title('Sparse representation of Laplacian L')
xlabel('Column Index')
ylabel('Row Index')

% ode solver wants vector, so reshape the matrix
An0 = reshape(rashBWDouble,nx*ny,1);

% Gaussian Diffusion Constant centered at pixel midpoint of rash
D = zeros(size(rashBWDouble));
centerX = 150;
centerY = 170;
% try sigma = 0.008
sigma = 0.012;
filterGauss = exp(-sigma*(Kx-centerX).^2-sigma*(Ky-centerY).^2)';

% try 0.003
D = filterGauss*0.005;
figure
surfl(Kx,Ky,D'), shading interp
xlabel('Kx')
ylabel('Ky')
zlabel('Magnitude')
title('Spatial Gaussian Diffusion Coefficient - D(x,y)')

D = reshape(D,nx*ny,1);
% 0 0.006 0.010 0.013

tspan = [0 0.006 0.009 0.03];
[t,A_sol] = ode45('image_rhsD',tspan,An0,[],L,D);

figure
for j=1:4
    subplot(2,2,j)
    Aclean = uint8(reshape(A_sol(j,:),nx,ny));
    imshow(Aclean)
    title(['Diffusion time of tspan = ',num2str(tspan(j))])
    axis([140 200 120 180 ])
    
    if j == 3
        aFinal = Aclean;
    end
end
subtitle('Spatial Diffusion for rash removal - Grayscale image')

figure
imshow(aFinal)
title('Final Locally Diffused Image - Grayscale')

%% do it in color

%
rashDoubleRed = rashColorDouble(:,:,1);
rashDoubleGreen = rashColorDouble(:,:,2);
rashDoubleBlue = rashColorDouble(:,:,3);

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
    title(['Diffusion time of tspan = ',num2str(tspan(j))])
    axis([140 200 120 180 ])
    if j == 3
        Rfinal = rashRclean;
    end
end
subtitle('Spatial Diffusion on Red Color Channel (in grayscale)')

% green

rashG = reshape(rashDoubleGreen,nx*ny,1);
[t,rashG_sol] = ode45('image_rhsD',tspan,rashG,[],L,D);

figure
for j=1:4
    subplot(2,2,j)
    % reshape into nx by ny image
    rashGclean = uint8(reshape(rashG_sol(j,:),nx,ny));
    imshow(rashGclean)
    title(['Diffusion time of tspan = ',num2str(tspan(j))])
    axis([140 200 120 180 ])
    
    if j == 3
        Gfinal = rashGclean;
    end
end
subtitle('Spatial Diffusion on Green Color Channel (in grayscale)')

% blue

rashB = reshape(rashDoubleBlue,nx*ny,1);
[t,rashB_sol] = ode45('image_rhsD',tspan,rashB,[],L,D);

figure
for j=1:4
    subplot(2,2,j)
    % reshape into nx by ny image
    rashBclean = uint8(reshape(rashB_sol(j,:),nx,ny));
    imshow(rashBclean)
    title(['Diffusion time of tspan = ',num2str(tspan(j))])
    axis([140 200 120 180 ])
    if j == 3
        Bfinal = rashBclean;
    end
end
subtitle('Spatial Diffusion on Blue Color Channel (in grayscale)')


rashClean = cat(3,Rfinal,Gfinal,Bfinal);
figure
imshow(rashClean)
title('Final Recombined Diffused Color Image')

