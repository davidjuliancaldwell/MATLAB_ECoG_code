%% First run up to the svd code of the main script, and run all channels through
% I notch filtered, but that probably doesn't mater.
% I set bad channels to the stim channel numbers, and good channels to all
% the other channels (but maybe this isn't really necessary, I just wanted
% SVD of all the channels except the stim ones).

% I also want access to the dataSVD, so re-run some of what was run in the
% SVDanalysis script just to get those variable in workspace for now.. 
data=dataStackedGood;
goods = zeros(size(data,2),1);
goods(goodChans) = 1;
goods = logical(goods);
dataTrim = data(:,goods);
size(data)
size(dataTrim)
dataSVD = dataTrim';
[u,s,v] = svd(dataSVD,'econ');

% %% data=dataStackedGood;
% stimChans=stim_chans;
% ignore=[];goodChans;
% 
% goods = zeros(size(data,2),1);
% goods(goodChans) = 1;
% goods = logical(goods);
% dataTrim = data(:,goods);
% size(data)
% size(dataTrim)
% dataSVD = dataTrim';
% [u,s,v] = svd(dataSVD,'econ');

%% Part 4 maybe? 
% Nathan: Plot the first few dominant modes (columns of U) by reshaping them back
% to spatial 2D patterns consistent with your measurement grid.

% This is basically taking the modes of u and plotting them on the grid as
% if, mode 1 is on Ch 1, mode 2 ch 2, etc. But this probably doesn't really
% make spatial sense

% For plotSignificantCCEPsMap, want time*channels. Since columns of u are
% usually what's of interest, we'll consider each column of u to be the
% 'channel' and so it doesn't need to be transposed
% But, it does need to have the stim channels added back in:

u_withStim = zeros(64-length(stim_chans),64);
temp = ones(1,64);
temp(stim_chans) = 0;
u_withStim(:,logical(temp)) = u;

% Note that changes were made to this function to make this work:
plotSignificantCCEPsMap(u_withStim,(0:length(u)-1),stim_chans,sigCCEPs, 'no');

%% OR for Part 4 maybe we're supposed to take those few dominant modes, project the data onto those modes and then plot on the grid
% This probably makes much more sense...

% First project the svd'd data onto the modes
modes=1:3;
data_proj=u(:,modes)*s(modes, modes)*v(:,modes)';

% Again add rows in for the stim channels
data_proj_withStim = zeros(64, size(data_proj,2));
temp = ones(64,1);
temp(stim_chans) = 0;
data_proj_withStim(logical(temp),:) = data_proj;

%% Now I see two ways of plotting this projected data:
% 1) either try to get back to a matrix with epochs,
% or, 2) just plot the entire data_proj rows which should show some
% periodicity since the original data was stacked which yields the peaks at
% every epoch start.

% Method 1:
% Now try to get back to a matrix with epochs (like dataEpochedHigh)
% Since we stacked 10 stim pulses of equal size
L = size(data_proj,2)/10;

% Want:  time(which should be L)*channels*epochs
sig = reshape(data_proj_withStim, [64, L, 10]);
sig = permute(sig, [2 1 3]);

plotSignificantCCEPsMap(sig,t(1:length(sig)),stim_chans,sigCCEPs, 'no');

%% Method 2:
% Don't reshape, want: time*channels
plotSignificantCCEPsMap(data_proj_withStim',(1:size(data_proj_withStim,2)),stim_chans,sigCCEPs, 'no');



%% Part 5???
% Nathan: 5.  Compute projection of each data matrix A_j onto mode U_i,
% U_i+1, U_i+2 and plot this projection in 3D with PLOT3.  You might want
% to consider starting with i=2 (ignore the “background mode” i=1).   Try
% also i=3, 4, 5..  until about where the rank truncation occurs.


% Try: plot projections in 3D (against one another)

%starting i
start=2;

A_proj = zeros(size(dataSVD, 1), size(dataSVD, 2), 3);

for i=start:start+3
    A_proj(:,:,i)=u(:,i)*s(i,i)*v(:,i)';
end

figure
plot3(A_proj(:,:,1), A_proj(:,:,2), A_proj(:,:,3))
% Rather than what you originally plotted (in pdf that you attached), which
% was the first 3 modes in time against one another, this is the data's
% projection onto those modes against one another

%% But that is using the dataSVD which is all the stacked data and not the individual A_j's
% % % so break up the SVD data:
% % sig = reshape(dataSVD, [62, L, 10]);
% % 
% % %Choose epoch:
% % epoch = 1;
% % 
% % figure
% % plot3(A_proj(:,:,1), A_proj(:,:,2), A_proj(:,:,3))


%% But, this doesn't account for the idea from Nathan:
% a_i   U(:,i).’ *U_j (:,i)   (i=2,3,4,…)
% 
% which results in a projection of mode i matrix of the local A_j PCA modes
% to the ith global PCA mode.

% I'm thinking now that this has to do with taking SVD's of ALL the data
% vs. SVD's of just the channels of interest... where global PCA means the
% components that were found when you consider all of the electrodes on
% grid whereas local PCA components are the ones from a PCA/SVD on just one
% electrode channel... 
% I also think that A_j refers to each channels*samples 'submatrix' that
% was stacked to form the whole A
% U_j: let's go with this is the u matrix of the 'local' A_j SVD
% whereas U_i or U(:,i) is the 'global' u from the SVD of the BIG A (all
% stim pulses) matrix

% So what we already did u, v, and s are the global modes
% Now calculate some 'local' modes
epoch=1; % choose epoch number
sig = reshape(dataSVD, [62, L, 10]);
[uL,sL,vL] = svd(sig(:,:,epoch), 'econ');

% for i=2:4
%     a(i) = u(:,i).'*uL(:,i); % this is what Nathan wrote, but it's just a
%     % scalar
% end

% for for a projection...
for i=2:4
    a(:,:,i) = u(:,i)*uL(:,i)'; 
end

figure
plot3(a(:,:,1), a(:,:,2), a(:,:,3))
% This does have distinct groupings in 3D space, but I don't know what that
% means... 

