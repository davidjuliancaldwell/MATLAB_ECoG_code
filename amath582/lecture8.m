%% AMATH 582 - Lecture 8 - 1/25/2016 
% denoising data 

clear all; close all; clc
A = imread('cap','jpeg');

% resize to certain number of pixels
A2 = imresize(A,[600 800]);

% scaling factor to maintain ratio
A3 = imresize(A,0.2);
% imshow(A3)

% make it black/white, double precision, so now we can math it up 
Abw = double(rgb2gray(A2));
At = fft2(Abw);

% add noise
noise = 10000;
Atn = At+noise*(randn(600,800)+i*randn(600,800));

% noisy image
An = ifft2(Atn);

% converted back to uint8 format for imshow
An2 = uint8(An);

% filter

kx=1:800; ky=1:600;

% make it 2d!;
[Kx,Ky] = meshgrid(kx,ky);

% make a loop to check out strength of stuff

%%
% add noise
close all;clear all;clc
A = imread('cap','jpeg');

% resize to certain number of pixels
A2 = imresize(A,[600 800]);
% make it black/white, double precision, so now we can math it up 
Abw = double(rgb2gray(A2));
At = fft2(Abw);
noise = 100000;
Atn = At+noise*(randn(600,800)+i*randn(600,800));

% filter

kx=1:800; ky=1:600;

% make it 2d!;
[Kx,Ky] = meshgrid(kx,ky);

sigma = [0.001 0.0001 0.00001 0];
figure
for j = 1:4
% center is at n/2 + 1, the way the FFT throws out stuff 
F = exp(-sigma(j)*(Kx-401).^2-sigma(j)*(Ky-301).^2); Ft = fftshift(F);
%figure(5)
%surfl(Kx,Ky,F), shading interp
Atf = Ft.*Atn;

% transformed domain
At = ifft2(Atf); 

subplot(2,2,j)
Af = uint8(At);
imshow(Af)

end
%%
% edges are high frequency in images, so you'll see blurring 

figure(1), imshow(A2)

% can see information much better with log, +1 
figure(2), pcolor(log(abs(fftshift(At))+1)), shading interp, colormap 'hot'
figure(3), pcolor(log(abs(fftshift(Atn))+1)), shading interp, colormap 'hot'
figure(4), imshow((An2))
figure(5), imshow(Af)

% when you take FFT, shift happens, multiplies every other one by negative
% one, everything gets scaled by factor of N, (multiplied by 600, then 800,
% etc) for 3rgb, have to fourier transform on EACH LEVEL, denoise, put it
% all back together, for natural images, there is a statistical
% distribution centered around zero. For natural images, we know where to
% put filter. if you know you want a certain part of an image, like
% writing, you have to change up the filter. Maybe a donut filter to select
% text, look at frequency content, then  go from there 