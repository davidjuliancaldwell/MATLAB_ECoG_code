% CSP_Test

N = 64;
T = 10;

trials = 1000;


randomChanList = randperm(N);

taskPosChans = randomChanList(1) + (-1:1);

while (min(taskPosChans) < 1)
    taskPosChans = taskPosChans + 1;
end

while (max(taskPosChans) > N)
    taskPosChans = taskPosChans - 1;
end

% synthesize data from class one
c1 = normrnd(0, 0.1, [N T trials]);
% c1 = zeros(N, T, trials);

for trial = 1:trials
    for chanIdx = 1:length(taskPosChans)        
        c1(taskPosChans(chanIdx),:,trial) = squeeze(c1(taskPosChans(chanIdx),:,trial)) + sin((1:T)/T*pi);
    end
end

plot(mean(c1,3)')

% synthesize data from class two
taskNegChans = randomChanList(2) + (-1:1);

while (min(taskNegChans) < 1)
    taskNegChans = taskNegChans + 1;
end

while (max(taskNegChans) > N)
    taskNegChans = taskNegChans - 1;
end

c2 = normrnd(0, 0.1, [N T trials]);

for trial = 1:trials
    for chanIdx = 1:length(taskNegChans)
        c2(taskNegChans(chanIdx),:,trial) = squeeze(c2(taskNegChans(chanIdx),:,trial)) + sin((1:T)/T*pi);
    end
end

%% perform CSP (the other way)

c1r = reshape(c1, [N T*trials]);
c2r = reshape(c2, [N T*trials]);

X = CSP(c1r, c2r);
X = X([1 end], :)';

plot(X);

% %% 
% for idx = 1:2
%     xi = find(X(:,idx) > .5);
%     fprintf('for class %d, the channels of interest are: ', idx);
%     fprintf('%d ', xi);
%     fprintf('\n');
% end
% 
% c1p = zeros(2, size(c1,2), size(c1,3));
% 
% for trial = 1:trials
%     temp = c1(:,:,trials)' * X;
%     plot(temp(:,1), temp(:,2));
%     hold on;
% %     c1p(:, :, trial) = (squeeze(c1(:,:,trials))' * W)';
% end
% 
% % plot(squeeze(c1p(1,:,:)), squeeze(c1p(2,:,:)), 'color', [.5 .5 .5]);
% % c2p = zeros(size(c2,2), size(c2,3));

%% let's try another test

% data is observations by channels
% label is observations

nchans = 64;
nobs = 50;
label = randi(2, [nobs, 1])-1;

modchans = randi(64, [5, 1]);
modstrength = .0;

data = [];
for chan = 1:nchans
    data(:, chan) = randn([nobs, 1]);
    
    if (ismember(chan, modchans))
        data(:, chan) = data(:, chan) + modstrength * label;
    end
end

rs = corr(data, label);
[~, irs] = sort(rs, 'descend');

% X = CSP(data(label==0, :)', data(label==1, :)');
% W = X([1 end], :)';
% % W = X(:, [1 end]);
% pdata = data * W;

[proj, filt, vf] = mpca(data(:, irs(1:10)));
figure
subplot(211);
gscatter(data(:, irs(1)), data(:, irs(2)), label);
subplot(212);
gscatter(proj(:, 1), proj(:,2), label);
