%% build the data

chans = 40;
obs = 50;
corrs = 3;

partition = cvpartition(obs, 'kfold', 5);

X = randn(obs, chans);

r_ind = randperm(chans,corrs);
r = zeros(chans, 1);
w = randn(corrs, 1);
r(r_ind) = w;

y = X * r + randn(obs, 1);
y = sign(y);

%% use lasso for parameter selection
[b, info] = lasso(X,y, 'CV', partition);
lassoPlot(b, info, 'PlotType', 'CV');
figure
lassoPlot(b, info);

%% build a classifier

Xp = X;
Xp(:, b(:, info.IndexMinMSE) == 0) = [];

figure
gscatter(Xp(:,1), Xp(:, 2), y);

cp = cvpartition(length(y),'k',10); % Stratified cross-validation

classf = @(XTRAIN, ytrain,XTEST)(classify(XTEST,XTRAIN,ytrain));

cr = 1 - crossval('mcr',Xp,y,'predfun',classf,'partition',cp)

%% determine chance classification

h = waitbar(0, 'dostuff');

for n = 1:1000
    waitbar(n/1000, h);
    
    idx = randi(chans);
    idxs = randperm(chans, idx);
    Xr = X(:, idxs);
    
    crr(n) = 1 - crossval('mcr',Xp,shuffle(y),'predfun',classf,'partition',cp);
end

close(h);

figure
histfit(crr);
vline(cr, 'k');