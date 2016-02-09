%% DJC HW1 for amath582

% first part from homework, notes provided 

clear all;close all;clc;
load Testdata

L=15; % spatial domain
n = 64; % fourier modes
x2 = linspace(-L,L,n+1); x=x2(1:n); y=x; z=x;
k = (2*pi/(2*L))*[0:(n/2-1) -n/2:-1]; ks = fftshift(k);

[X,Y,Z]=meshgrid(x,y,z);
[Kx,Ky,Kz] = meshgrid(ks,ks,ks);
%
for j=1:20
    if (j == 5)
        Un(:,:,:)=reshape(Undata(j,:),n,n,n);
        %original value was 0.4 for isosurface
        isosurfaceVal = 0.9;
        close all, isosurface(X,Y,Z,abs(Un),isosurfaceVal)
        axis([-20 20 -20 20 -20 20]), grid on, drawnow
        %     pause(1)
        xlabel('X','FontWeight','bold')
        ylabel('Y','FontWeight','bold')
        zlabel('Z','FontWeight','bold')
        title(sprintf('Raw spatial data for %d-th measurement \n Isosurface value = %d',j,isosurfaceVal))
    end
    
end
%% compute average
ave = zeros(n,n,n);

for j = 1:20
    Un(:,:,:)=reshape(Undata(j,:),n,n,n);
    Unt = fftn(Un);
    %    UndataT(j,:) = reshape
    ave = ave + Unt;
end

ave = (ave)./20;
close all
[maxT,id] = max(abs(ave(:)));
isosurface(Kx,Ky,Kz,abs(fftshift(ave))./maxT,0.5)
xlabel('Kx','FontWeight','bold')
ylabel('Ky','FontWeight','bold')
zlabel('Kz','FontWeight','bold')


[a,b,c] = ind2sub(size(ave),id);
% aK = k(a);
% bK = k(b);
% cK = k(c);

% this is to make a meshgrid of the UNSHIFTED coordinates 
[Kx2,Ky2,Kz2] = meshgrid(k,k,k);
aK = Kx2(a,b,c);
bK = Ky2(a,b,c);
cK = Kz2(a,b,c);

hold on
fig1 = plot3(aK,bK,cK,'m*','MarkerSize',10);
legend(fig1,{'Point of maximum FFT magnitude'})
title('Plot of FFT Magnitude vs K wavenumbers in X,Y,Z spatial directions')

% output to the user the spatial frequency numbers where the magnitude of
% the FFT is the great
sprintf('The K numbers for the greatest magnitude of the averaged signal FFT are X = %d, Y = %d, Z = %d',bK,aK,cK)


%% begin filtering

% tau is to determine the width of the Gaussian
tau = 1.5;
[Kx2,Ky2,Kz2] = meshgrid(k,k,k);

% create the 3D Gaussian filter using the UNSHIFTED K values, in order to
% match the output from the fft
filter = (exp(-tau*(Kx2-aK).^2)).*(exp(-tau*(Ky2-bK).^2))...
    .*(exp(-tau*(Kz2-cK).^2));



% plot the Gaussian filter
close all,isosurface(Kx,Ky,Kz,fftshift(filter),0.6),...
    axis([-7 7 -7 7 -7 7]), grid on, drawnow
xlabel('Kx','FontWeight','bold')
ylabel('Ky','FontWeight','bold')
zlabel('Kz','FontWeight','bold')
title(sprintf('Spatial Frequencies selected by the 3D Frequency Domain Gaussian Filter \n Isovalue of 0.6'))

% begin making the Trajectory
trajA = [];
trajB = [];
trajC = [];

%% extract the noisy spatial distance measurements
for j=1:20
    Un(:,:,:)=reshape(Undata(j,:),n,n,n);
    Unt = fftn(Un);
    
    % filter the signal by doing a pointwise multiplication of the signal
    % at each measurement point with the filter 
    Ut = filter.*Unt;
    
    % take the inverse Fourier transform
    Unf = ifftn(Ut);
    
    % find the indices of the maximum signal value 
    [maximUnf,I] = max(abs(Unf(:)));
    [a,b,c] = ind2sub(size(Unf),I);
    
    % plot example for j == 5
    if j == 5
        
%         %                 plot filtered
%         close all, isosurface(Kx,Ky,Kz,fftshift(abs(Ut)./max(abs(Ut(:)))),0.1)
%         axis([-7 7 -7 7 -7 7]), grid on, drawnow
%         xlabel('Kx','FontWeight','bold')
%         ylabel('Ky','FontWeight','bold')
%         zlabel('Kz','FontWeight','bold')
%         title(sprintf('Normalized Magnitude of the FFT \n for Gaussian Filtered Signal for %d-th Measurement \n in the Spatial Frequency Domain',j))
%         
%         plot original
        close all, isosurface(Kx,Ky,Kz,fftshift(abs(Unt)./max(abs(Unt(:)))),0.5)
        axis([-7 7 -7 7 -7 7]), grid on, drawnow
        xlabel('Kx','FontWeight','bold')
        ylabel('Ky','FontWeight','bold')
        zlabel('Kz','FontWeight','bold')
        title(sprintf('Normalized Magnitude of  the FFT \n of the Original Signal for the %d-th Measurement \n in Spatial Frequency Domain',j))
        
%         
        
        % update the trajectory as time goes along
        trajA = [trajA X(a,b,c)];
        trajB = [trajB Y(a,b,c)];
        trajC = [trajC Z(a,b,c)];
        
        % plot the spatial distance
        close all,isosurface(X,Y,Z,abs(Unf)/max(abs(Unf(:))),0.6)
        axis([-20 20 -20 20 -20 20]), grid on, drawnow
        xlabel('X','FontWeight','bold')
        ylabel('Y','FontWeight','bold')
        zlabel('Z','FontWeight','bold')
        hold on
        plot3(trajA,trajB,trajC)
        
    end
    
    % plot 3D trajectory from maximum values
    
    fig2 = plot3(trajA,trajB,trajC,'Color','m','LineWidth',2,'Marker','o')
    
    title('Trajectory of Marble and final location at 20th measurement')
    
    legend(fig2,{'Trajectory of Marble'})
    
    % output to user the location of where the acoustic wave should be focused
    sprintf('The location where the acoustic wave should be focused is X = %d, Y = %d, Z = %d',trajA(end),trajB(end),trajC(end))

end