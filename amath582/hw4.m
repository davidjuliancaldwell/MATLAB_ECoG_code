%% David Caldwell - hw # 4 - amath 582


%% test 1
% close all; clear all;clc
% load cam1_1.mat
% load cam2_1.mat
% load cam3_1.mat

%%
cd c:\users\david\desktop\Research\RaoLab\MATLAB\Code\amath582
close all; clear all;clc
load cam1_1.mat
numFrames = size(vidFrames1_1,4);

% look at part 1
vidFrames = vidFrames1_1;

% for j=1:numFrames
%     X=vidFrames(:,:,:,j);
%     imshow(X); drawnow
% end
%
for i = 1:size(vidFrames,4)
    vidFramesDoub(:,:,i) = double(rgb2gray(vidFrames(:,:,:,i)));
end

% takea  look at it
% imagesc(vidFramesDoub(:,:,1)),colormap('gray')

% try from matlab acquiring
% http://www.mathworks.com/company/newsletters/articles/tracking-objects-acquiring-and-analyzing-image-sequences-in-matlab.html

% for i = 2:numFrames
%     vidFramesSubbed(:,:,i) = ( vidFramesDoub(:,:,i) - (vidFramesDoub(:,:,i-1)) );
% end

% figure
% % take a look at it subtracted?
% imagesc(vidFramesSubbed(:,:,30)),colormap('gray')

% subtract mean
averageIm = mean(vidFramesDoub,3);
vidFramesDoub = abs (vidFramesDoub - repmat(averageIm,1,1,numFrames));

a = vidFramesDoub(:,:,1);
[maxi,loc] = (max(a(:)));
[x,y] = ind2sub(size(a),loc);
fs = 75;
Fs = zeros(size(a));
Fs(x-fs:1:x+fs,y-fs:1:y+fs) = ones(2*fs+1,2*fs+1);
filtered = Fs.*a;

imagesc(filtered),colormap('gray')
hold on
plot(y,x,'ro','Linewidth',[2]);

% figure
xVec1 = [];
yVec1 = [];
for j=1:numFrames
    if j == 1
        a = vidFramesDoub(:,:,1);
        [maxi,loc] = (max(a(:)));
        [x,y] = ind2sub(size(a),loc);
        fs = 50;
        Fs = zeros(size(a));
        Fs(x-fs:1:x+fs,y-fs:1:y+fs) = ones(2*fs+1,2*fs+1);
        filtered = Fs.*a;
        [m,n] = find(filtered>=75);
        aveM = median(m);
        aveN = median(n);
        xVec1 = [xVec1; aveM];
        yVec1 = [yVec1; aveN];
        
        hold on
        imagesc(filtered); colormap('gray'); plot(aveN,aveM,'ro','Linewidth',[2]); drawnow
        hold off
    else
        a = vidFramesDoub(:,:,j);
        filtered = Fs.*a;
        imagesc(filtered); colormap('gray'); hold on; plot(aveN,aveM,'ro','Linewidth',[2]); drawnow; hold off

        [maxi,loc] = (max(filtered(:)));
        [x,y] = ind2sub(size(filtered),loc);
        fs = 50;
        Fs = zeros(size(a));
        
        b = find(filtered(:)>=75);
        [x,y] = ind2sub(size(a),b);
        aveM = round(median(x));
        aveN = round(median(y));
        xVec1 = [xVec1; aveM];
        yVec1 = [yVec1; aveN];
        
        % make filter for next iteration
        Fs = zeros(size(a));

        Fs(aveM-fs:1:aveM+fs,aveN-fs:1:aveN+fs) = ones(2*fs+1,2*fs+1);
       
%         imagesc(a); colormap('gray'); hold on; plot(aveN,aveM,'ro','Linewidth',[2]); drawnow
%         hold off
    end
    

    
end

% figure
% for j=1:numFrames
%     X = uint8(vidFramesSubbed(:,:,j));
%     imshow(X); drawnow
% end

t = 1:length(xVec1);
figure
subplot(2,1,1)
plot(t',xVec1,'ko');
subplot(2,1,2)
plot(t',yVec1,'ko');

clearvars -except xVec1 yVec1
%% try it for two and 3
load cam2_1.mat
numFrames = size(vidFrames2_1,4);

% look at part 2
vidFrames = vidFrames2_1;

% for k = 1 : numFrames
%     mov(k).cdata = vidFrames(:,:,:,k);
%     mov(k).colormap = [];
% end
% for j=1:numFrames
%     X=frame2im(mov(j));
%     imshow(X); drawnow
% end

for i = 1:size(vidFrames,4)
    vidFramesDoub2(:,:,i) = double(rgb2gray(vidFrames(:,:,:,i)));
end

imagesc(vidFramesDoub2(:,:,1)),colormap('gray')
% takea  look at it
% imagesc(vidFramesDoub2(:,:,1)),colormap('gray')

% try from matlab acquiring
% http://www.mathworks.com/company/newsletters/articles/tracking-objects-acquiring-and-analyzing-image-sequences-in-matlab.html


% find mean? subtract that?


for i = 3:numFrames
    vidFramesSubbed2(:,:,i) = abs(vidFramesDoub2(:,:,i) - (vidFramesDoub2(:,:,i-1)));
end
%
% figure
% % take a look at it subtracted?
% imagesc(vidFramesSubbed2(:,:,4)),colormap('gray')
%
% a = vidFramesSubbed(:,:,4);
% [maxi,loc] = (max(a(:)));
% [x,y] = ind2sub(size(a),loc);
% hold on
% plot(y,x,'ro','Linewidth',[2]);
%
% figure
xVec2 = [];
yVec2 = [];
for j=1:numFrames
    a = vidFramesSubbed2(:,:,j);
    [maxi,loc] = (max(a(:)));
    [x,y] = ind2sub(size(a),loc);
    xVec2 = [xVec2; x];
    yVec2 = [yVec2; y];
    %     hold on
    %     imagesc(a); colormap('gray'); plot(y,x,'ro','Linewidth',[2]); drawnow
    %     hold off
end

% figure
% for j=1:numFrames
%     X = uint8(vidFramesSubbed2(:,:,j));
%     imshow(X); drawnow
% end

t = 1:length(xVec2);
figure
subplot(2,1,1)
plot(t',xVec2,'ko');
subplot(2,1,2)
plot(t',yVec2,'ko');

clearvars -except xVec1 yVec1 xVec2 yVec2

%% for 3
load cam3_1.mat
numFrames = size(vidFrames3_1,4);

% look at part 3
vidFrames = vidFrames3_1;

% for k = 1 : numFrames
%     mov(k).cdata = vidFrames(:,:,:,k);
%     mov(k).colormap = [];
% end
% for j=1:numFrames
%     X=frame2im(mov(j));
%     imshow(X); drawnow
% end

for i = 1:size(vidFrames,4)
    vidFramesDoub3(:,:,i) = double(rgb2gray(vidFrames(:,:,:,i)));
end

imagesc(vidFramesDoub3(:,:,1)),colormap('gray')

%
% % takea  look at it
% imagesc(vidFramesDoub3(:,:,1)),colormap('gray')

% try from matlab acquiring
% http://www.mathworks.com/company/newsletters/articles/tracking-objects-acquiring-and-analyzing-image-sequences-in-matlab.html


% find mean? subtract that?


for i = 3:numFrames
    vidFramesSubbed3(:,:,i) = abs(vidFramesDoub3(:,:,i) - (vidFramesDoub3(:,:,i-1)));
end

% figure
% % take a look at it subtracted?
% imagesc(vidFramesSubbed3(:,:,4)),colormap('gray')
%
% a = vidFramesSubbed3(:,:,4);
% [maxi,loc] = (max(a(:)));
% [x,y] = ind2sub(size(a),loc);
% hold on
% plot(y,x,'ro','Linewidth',[2]);

% figure
xVec3 = [];
yVec3 = [];
for j=1:numFrames
    a = vidFramesSubbed3(:,:,j);
    [maxi,loc] = (max(a(:)));
    [x,y] = ind2sub(size(a),loc);
    xVec3 = [xVec3; x];
    yVec3 = [yVec3; y];
    %     hold on
    %     imagesc(a); colormap('gray'); plot(y,x,'ro','Linewidth',[2]); drawnow
    %     hold off
end

% figure
% for j=1:numFrames
%     X = uint8(vidFramesSubbed3(:,:,j));
%     imshow(X); drawnow
% end

t = 1:length(xVec3);
figure
subplot(2,1,1)
plot(t',xVec3,'ko');
subplot(2,1,2)
plot(t',yVec3,'ko');

clearvars -except xVec1 yVec1 xVec2 yVec2 xVec3 yVec3

%%
% plot them all together
figure
t1 = 0:length(xVec1)-1;
t2 = 0:length(xVec2)-1;
t3 = 0:length(xVec3)-1;

subplot(3,2,1)
plot(t1',xVec1,'go');
title('Camera 1 x')

subplot(3,2,2)
plot(t1',yVec1,'go');
title('Camera 1 y')

subplot(3,2,3)
plot(t2',xVec2,'ro')
title('Camera 2 x')

subplot(3,2,4)
plot(t2',yVec2,'ro')
title('Camera 2 y')

subplot(3,2,5)
plot(t3',xVec3,'bo')
title('Camera 3 x')

subplot(3,2,6)
plot(t3',yVec3,'bo')
title('Camera 3 y')

%%

% make them the same length
tCut = min([length(xVec1),length(xVec2),length(xVec3)]);

xVec2 = xVec2(1:tCut);
yVec2 = yVec2(1:tCut);
xVec3 = xVec3(1:tCut);
yVec3 = yVec3(1:tCut);


%% SVD
% make the matrix
close all
vidMatrix = [xVec1'; yVec1'; xVec2'; yVec2'; xVec3'; yVec3'];

% normalize the SVD matrix usinge elementwise operators and repmat
aver = mean(vidMatrix,2);
stdDev = std(vidMatrix,0,2);
vidMatrixNorm = vidMatrix - repmat(aver,1,size(vidMatrix,2));

% don't need to normalize by standard deviation?
% vidMatrixNorm = vidMatrixNorm./(repmat(stdDev,1,size(vidMatrix,2)));

% plot normalized
t = 0:size(vidMatrixNorm,2)-1;
figure

subplot(3,2,1)
plot(t',vidMatrixNorm(1,:)','go');
title('Camera 1 x')

subplot(3,2,2)
plot(t',vidMatrixNorm(2,:)','go');
title('Camera 1 y')

subplot(3,2,3)
plot(t',vidMatrixNorm(3,:)','ro')
title('Camera 2 x')

subplot(3,2,4)
plot(t',vidMatrixNorm(4,:)','ro')
title('Camera 2 y')

subplot(3,2,5)
plot(t',vidMatrixNorm(5,:)','bo')
title('Camera 3 x')

subplot(3,2,6)
plot(t',vidMatrixNorm(6,:)','bo')
title('Camera 3 y')

% reduced gives you NOT square matrix, econ only gives you out what you
% want. In GENERAL, use economy method
[u,s,v] = svd(vidMatrixNorm,'econ');

% figure(1)
% surfl(X,T,f),% shading interp, colormap(hot)

% look at diagonal of matrix S - singular values
figure
plot(diag(s),'ko','Linewidth',[2])
title('Singular Values of SVD Decomposition')

figure
% to get percentage in mode
subplot(2,1,1) % plot normal
plot(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
title('Plot of percentage of variance explained by each mode')
subplot(2,1,2) % plot semilog
semilogy(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
title('Log axis')

% look at the modes
figure
x = 1:length(u);
plot(x,u(:,1:6),'Linewidth',[2])

% look at temporal part - columns of v
figure
t = 1:226;
plot(t,v(:,1:6),'Linewidth',[2])


%% look at part 2
close all; clear all;clc
load cam3_4.mat
vidFrames = vidFrames3_4;


numFrames = size(vidFrames,4);


% for j=1:numFrames
%     X=vidFrames(:,:,:,j);
%     imshow(X); drawnow
% end
%
for i = 1:size(vidFrames,4)
    vidFramesDoub(:,:,i) = double(rgb2gray(vidFrames(:,:,:,i)));
end

% takea  look at it
imagesc(vidFramesDoub(:,:,1)),colormap('gray')


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
% 
% obj=mmreader(’matlab_test.mov’)
% vidFrames = read(obj);
% 
% numFrames = get(obj,’numberOfFrames’);
% for k = 1 : numFrames
%     mov(k).cdata = vidFrames(:,:,:,k);
%     mov(k).colormap = [];
% end
% for j=1:numFrames
%     X=frame2im(mov(j));
%     imshow(X); drawnow
% end