function [tmeans, p_min, p_max]  = changeTScoreWithStatsParallel( power, post_power, windowSize )

%% trim to even length
if size(power,1) < size(post_power,1) %use the shorter one, and round to a multiple of window size
    newLength = size(power,1) - mod(size(power,1), windowSize);
else
    newLength = size(post_power,1) - mod(size(post_power,1), windowSize);
end

power = power(1:newLength, :);
post_power = post_power(1:newLength, :);

%% first the actual values
windowStart = 1;
windowEnd = windowSize;

changePlvs = zeros(size(power,2), size(power,2), 0);
prePlvs = zeros(size(power,2), size(power,2), 0);
postPlvs = zeros(size(power,2), size(power,2), 0);

while windowEnd <= size(power,1);
    
    thisWindow = power(windowStart:windowEnd, :);
    thisWindow_post = post_power(windowStart:windowEnd, :);
    thisWindowPlv = plv_revised(thisWindow);
    thisWindowPlv_post = plv_revised(thisWindow_post);
    
    thisWindowPlv_diff = thisWindowPlv_post - thisWindowPlv;
    
    changePlvs = cat(3, changePlvs, thisWindowPlv_diff);
    prePlvs = cat(3, prePlvs, thisWindowPlv);
    postPlvs = cat(3, postPlvs, thisWindowPlv_post);
    
    windowStart = windowStart + windowSize;
    windowEnd = windowEnd + windowSize;
end

allPlvs = cat(3, prePlvs, postPlvs);
std_dev = std(allPlvs, 0, 3);

tmeans=(mean(prePlvs,3)-mean(postPlvs,3))./std_dev;


%% and now for the permutation testing

nsegments = newLength/windowSize; % number of segments over which PLV is computed
nchannels=size(power,2); % number of ecog channels

npairs=(nchannels^2-nchannels)/2; % number of pairs
  
tic
 
nperm=10000;
p_sig=0.05;
 
max_histogram=zeros(nperm,1);
min_histogram=zeros(nperm,1);
 
parforfor i=1:nperm;
    ix=randperm(2*nsegments);
    Ap=allPlvs(:,:,ix(1:nsegments));
    Bp=allPlvs(:,:,ix(nsegments+1:end));
    t_perm=(mean(Ap,3)-mean(Bp,3))./std_dev;
    max_histogram(i)=max(t_perm(:));
    min_histogram(i)=min(t_perm(:));
end

toc

tmeans_reshape = reshape(tmeans, nchannels*nchannels, 1);
p_max=sum(repmat(tmeans_reshape,1,nperm)<repmat(max_histogram',nchannels*nchannels,1),2)/nperm;

p_max = reshape(p_max, nchannels, nchannels);

p_min=sum(repmat(reshape(tmeans, nchannels*nchannels, 1),1,nperm)>repmat(min_histogram',nchannels*nchannels,1),2)/nperm;

p_min = reshape(p_min, nchannels, nchannels);


end