%% David Caldwell - hw # 4 - amath 582


%% test 1
close all; clear all;clc
load cam1_1.mat
load cam2_1.mat
load cam3_1.mat

%%
close all; clear all;clc
load cam1_1.mat
numFrames = size(vidFrames1_1,4);

% look at part 1
vidFrames = vidFrames1_1;

for k = 1 : numFrames
    mov(k).cdata = vidFrames(:,:,:,k);
    mov(k).colormap = [];
end
for j=1:numFrames
    X=frame2im(mov(j));
    imshow(X); drawnow
end

for i = 1:size(vidFrames,4)
    vidFramesDoub(:,:,i) = double(rgb2gray(vidFrames(:,:,:,i)));
end

% takea  look at it
imagesc(vidFramesDoub(:,:,1)),colormap('gray')


% find mean? subtract that?

averaged = mean(vidFramesDoub,3);

for i = 1:size(vidFramesDoub,3)
    vidFramesSubbed(:,:,i) = vidFramesDoub(:,:,i) - averaged;
end

figure
% take a look at it subtracted?
imagesc(vidFramesSubbed(:,:,4)),colormap('gray')
a = vidFramesSubbed(:,:,4);
[maxi,loc] = (max(a(:)));
[x,y] = ind2sub(size(a),loc);
hold on
plot(y,x,'ro','Linewidth',[2]);

figure
for j=1:numFrames
    a = vidFramesSubbed(:,:,j);
    [maxi,loc] = (max(a(:)));
    [x,y] = ind2sub(size(a),loc);
    hold on
    imagesc(a); colormap('gray'); plot(y,x,'ro','Linewidth',[2]); drawnow
    hold off 
end

figure
for j=1:numFrames
    X = uint8(vidFramesSubbed(:,:,j));
    imshow(X); drawnow
end

% reduced gives you NOT square matrix, econ only gives you out what you
% want. In GENERAL, use economy method
[u,s,v] = svd(vidFramesSubbed,'econ');

figure(1)
surfl(X,T,f),% shading interp, colormap(hot)

% look at diagonal of matrix S - singular values
figure(2)
plot(diag(s),'ko','Linewidth',[2])

% to get percentage in mode
subplot(2,1,1) % plot normal
plot(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
subplot(2,1,2) % plot semilog
semilogy(diag(s)/sum(diag(s)),'ko','Linewidth',[2])

% look at the modes
figure(3)
plot(x,u(:,1:3),'Linewidth',[2])

% look at temporal part - columns of v
plot(t,v(:,1:3),'Linewidth',[2])


%% look at part 2
close all; clear all;clc
load cam2_1.mat
vidFrames = vidFrames2_1;

for k = 1 : numFrames
    mov(k).cdata = vidFrames(:,:,:,k);
    mov(k).colormap = [];
end
for j=1:numFrames
    X=frame2im(mov(j));
    imshow(X); drawnow
end

%% look at part 3
close all; clear all;clc
load cam3_1.mat
vidFrames = vidFrames3_1;

for k = 1 : numFrames
    mov(k).cdata = vidFrames(:,:,:,k);
    mov(k).colormap = [];
end
for j=1:numFrames
    X=frame2im(mov(j));
    imshow(X); drawnow
end



%% test 2
close all; clear all;clc
load cam1_2.mat
load cam2_2.mat
load cam3_2.mat

%% test 3
close all; clear all;clc
load cam1_3.mat
load cam2_3.mat
load cam3_3.mat

%% test 4
close all; clear all;clc
load cam1_4.mat
load cam2_4.mat
load cam3_4.mat

%% how to read in

obj=mmreader(’matlab_test.mov’)
vidFrames = read(obj);

numFrames = get(obj,’numberOfFrames’);
for k = 1 : numFrames
    mov(k).cdata = vidFrames(:,:,:,k);
    mov(k).colormap = [];
end
for j=1:numFrames
    X=frame2im(mov(j));
    imshow(X); drawnow
end