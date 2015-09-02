%%
Z_Constants;
addpath ./scripts;

%% perform analyses

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject
    fprintf(' loading data: ');    
    tic
    load(fullfile(META_DIR, [sid '_epochs']), 't', 'preDur', 'fbDur', 'epochs_hg', 'tgts', 'ress');
    [~,~,bads,~,cchan] = filesForSubjid(sid);
    toc

    data(sIdx).features = epochs_hg(:,:,t > -preDur & t <= fbDur);        
    data(sIdx).time = t(t > -preDur & t <= fbDur)';
    data(sIdx).labels = tgts;
    data(sIdx).results = ress;
    data(sIdx).controlChannel = cchan;

    data(sIdx).controlFeatures = squeeze(epochs_hg(cchan, :, t > -preDur & t <= fbDur));
    
    % perform feature downselection
    data(sIdx).isTraining = zeros(size(tgts));
    data(sIdx).isTraining(1:16) = 1;
    data(sIdx).isTraining = data(sIdx).isTraining == 1;
    
%     % perform CSP
%     %  currently, because of computational limitations, we're only
%     %  including grid data in CSP
%     cspData = data(sIdx).features(1:64,:,data(sIdx).time > 0);
% 
%     allChans = true(size(cspData, 1), 1);
%     allChans(bads) = 0;
%     
%     c1 = cspData(allChans, data(sIdx).isTraining & data(sIdx).labels == 1, :);
%     c1 = reshape(c1, [size(c1, 1), size(c1, 2)*size(c1, 3)]);
%     c2 = cspData(allChans, data(sIdx).isTraining & data(sIdx).labels == 2, :);
%     c2 = reshape(c2, [size(c2, 1), size(c2, 2)*size(c2, 3)]);
%     X = CSP(c1, c2);
% %     plot(X([1:2 (end-1):end], :)');
% 
%     % determine mixing matrix    
%     nCSPFeatures = 10; % must be even    
%     W = X([1:(nCSPFeatures/2) (end-nCSPFeatures/2+1):end], :)';
% 
%     preMix = data(sIdx).features(1:64, :, :);    
%     postMix = zeros([nCSPFeatures, size(preMix, 2), size(preMix, 3)]);
%     for trial = 1:size(preMix, 2)
%         postMix(:, trial, :) = (squeeze(preMix(allChans,trial,:))'*W)';
%     end
%     
%     data(sIdx).CSPDownselectedFeatures = postMix;
% 
%     % PCA    
%     [proj, W_pca, varfrac] = mpca(cat(2, c1, c2)');
%     nPCAFeatures = 10;
%     postMix = zeros([nPCAFeatures, size(preMix, 2), size(preMix, 3)]);
%     for trial = 1:size(preMix, 2)
%         postMix(:, trial, :) = (squeeze(preMix(allChans, trial, :))'*W_pca(:,1:nPCAFeatures))';
%     end
%     
%     data(sIdx).PCADownselectedFeatures = postMix;
end

%% 
notes = ['run this:\n', ...
         '  fprintf(notes);\n', ...
         'data is a 1-D struct array with N elements corresponding to the N subjects listed in the cell array SIDS. \n' ...
         'the struct contains the following fields: \n' ...
         '  features is a Chan x Trials x Samples matrix of high-gamma neural data\n' ...
         '  time is a Samples x 1 vector of time (in seconds) within the trial, t > 0 corresponds to active cursor control\n' ...
         '  labels is a Trials x 1 vector of the targets that the users were instructed to hit \n' ...
         '  results is a Trials x 1 vector of the targets that the users actually hit \n' ...         
         '  controlChannel is the channel that was actually used for control by the subject \n' ...
         '  isTraining is a Trials x 1 boolean vector of flags identifying trials that were used to train the channel mixing algorithm\n' ...
         '  CSPDownselectedFeatures is a CSPChan x Trials x Samples matrix of downmixed neural data such that the two most extreme channels (1 and end) correspond to the two channels that best separate the two classes\n' ...
         '  PCADownselectedFeatures is a PCAChan x Trials x Samples matrix of downmixed neural data, sorted in order of variance described\n' ...
         ];
     
% save(fullfile(META_DIR, 'features.mat'), 'data', 'SIDS', 'notes');
svdata = data;
data = rmfield(data, 'features');
save(fullfile(META_DIR, 'features-ctl.mat'), 'data', 'SIDS', 'notes');

% %%
% 
% temp = data(end).PCADownselectedFeatures([1 2], :, :);
% foo1 = squeeze(mean(temp(:, tgts==1, :), 2));
% foo2 = squeeze(mean(temp(:, tgts==2, :), 2));
% plot(cat(1, foo1, foo2)')
% legend('up-pos', 'up-neg', 'dn-pos', 'dn-neg')

%% here's a little code just to look at the features to make sure nothing crazy is going on

for c = 1:11
    figure;
    sid = SIDS{c};
    [~,~,bads,~,cchan] = filesForSubjid(sid);
    foo = mean(svdata(c).features(:,:,200:end),3);
    foo(bads,:) = 0;
    imagesc(foo);
    xlabel('trials');
    ylabel('trodes');
    hline(cchan,'k');
    vline(find(svdata(c).labels==1));
    title(sid);
end

    