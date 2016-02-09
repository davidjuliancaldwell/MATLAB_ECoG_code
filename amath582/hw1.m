%% DJC HW1 for amath582

% first part from homework

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

%% above is provided, below is my own work
%
% ave = zeros(1,n);
%
% UndataT = fft(Undata,[],2);
% ave = mean(UndataT,1);
% ave = abs(fftshift(ave))/20;
% plot(ks,ave/max(ave),'k')

%% try again
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
aK = k(a)
bK = k(b)
cK = k(c)

hold on
fig1 = plot3(bK,aK,cK,'m*','MarkerSize',10);
sprintf('The K numbers for the greatest magnitude of the averaged signal FFT are X = %d, Y = %d, Z = %d',bK,aK,cK)
legend(fig1,{'Point of maximum FFT magnitude'})
title('Plot of FFT Magnitude vs K wavenumbers in X,Y,Z spatial directions')

% a = 2;
% b = -1;
% c = 0;

% looks like Ky wavenumber = -1.0471, Kx  = 1.885, Kz = 0

%% filter dat
% try 0.9 for shape

%%
tau = 1.5;
filterKx = exp(-tau*(k-aK).^2);
filterKy = exp(-tau*(k-bK).^2);
filterKz = exp(-tau*(k-cK).^2);

[Kx2,Ky2,Kz2] = meshgrid(k,k,k);
filter = (exp(-tau*(Ky2-aK).^2)).*(exp(-tau*(Kx2-bK).^2)).*(exp(-tau*(Kz2-cK).^2));
close all,isosurface(Kx,Ky,Kz,fftshift(filter),0.6),axis([-7 7 -7 7 -7 7]), grid on, drawnow
xlabel('Kx','FontWeight','bold')
ylabel('Ky','FontWeight','bold')
zlabel('Kz','FontWeight','bold')
title(sprintf('Spatial Frequencies selected by the 3D Frequency Domain Gaussian Filter \n Isovalue of 0.6'))
% %
% figure
% plot(fftshift(k),fftshift(filterKx))
% figure
% plot(fftshift(k),fftshift(filterKy))
%
% figure
% plot(fftshift(k),fftshift(filterKz))
%
% %
% [filterMesKx,filterMeshKy,filterMeshKz] = meshgrid(filterKx,filterKy,filterKz);
% close all;
% surf(filterMeshKx,filterMeshKy,filterMeshKz)

trajA = [];
trajB = [];
trajC = [];

%%
for j=1:20
    Un(:,:,:)=reshape(Undata(j,:),n,n,n);
    Unt = fftn(Un);
    
%     DJC - way of multiplying sheet by sheet
%         for a = 1:length(filterKx)
%             Ut(a,:,:) = Unt(a,:,:)*filterKx(a);
%         end
%     
%         for a = 1:length(filterKy)
%             Ut(:,a,:) = Ut(:,a,:)*filterKy(a);
%         end
%     
%         for a = 1:length(filterKy)
%             Ut(:,:,a) = Ut(:,:,a)*filterKz(a);
%         end
%     
    % filter all at once
    Ut = filter.*Unt;
    if j == 5
        
%                 plot filtered
        close all, isosurface(Kx,Ky,Kz,fftshift(abs(Ut)./max(abs(Ut(:)))),0.1)
        axis([-7 7 -7 7 -7 7]), grid on, drawnow
        xlabel('Kx','FontWeight','bold')
        ylabel('Ky','FontWeight','bold')
        zlabel('Kz','FontWeight','bold')
        title(('Gaussian Filtered Signal for %d-th Measurement in Spatial Frequency Domain')
            pause(1)
        
            % plot original
        close all, isosurface(Kx,Ky,Kz,fftshift(abs(Unt)./max(abs(Unt(:)))),0.4)
        axis([-7 7 -7 7 -7 7]), grid on, drawnow
        xlabel('Kx','FontWeight','bold')
        ylabel('Ky','FontWeight','bold')
        zlabel('Kz','FontWeight','bold')
        title(sprintf('Originalfor %d-th Measurement in Spatial Frequency
        Domain',j))
        
    end
    Unf = ifftn(Ut);
    [maximUnf,I] = max(abs(Unf(:)));
    [a,b,c] = ind2sub(size(Unf),I);
    trajA = [trajA x(a)];
    trajB = [trajB x(b)];
    trajC = [trajC x(c)];
    %original value was 0.4 for isosurface
    %     close all, isosurface(X,Y,Z,abs(Unf),0.8)
        close all,isosurface(X,Y,Z,abs(Unf)/max(abs(Unf(:))),0.6)
        axis([-20 20 -20 20 -20 20]), grid on, drawnow
        xlabel('X','FontWeight','bold')
        ylabel('Y','FontWeight','bold')
        zlabel('Z','FontWeight','bold')
        hold on
        plot3(trajB,trajA,trajC)
        %     pause(1)
        
        % on 20th measurement, looks like marble is at x = 7.5, Y = -15, z = -8
        % from a,b,c, it's 7.5, -15, -8.4375
    
    
end

% plot 3D trajectory from maximum values
fig2 = plot3(trajB,trajA,trajC,'Color','m','LineWidth',2,'Marker','o')
title('Trajectory of Marble and final location at 20th measurement')
legend(fig2,{'Trajectory of Marble'})


sprintf('The location where the acoustic wave should be focused is X = %d, Y = %d, Z = %d',trajB(end),trajA(end),trajC(end))
