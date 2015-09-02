Z_Constants;

addpath ./scripts;

METHOD = 'lasso';
N_FOLDS = 10;
TIME_STEP = 1;

% METHOD = 'slda';

%% make the performance plot

for c = 1:length(SIDS);
    sid = SIDS{c};
    fprintf('working on subject %s\n', sid);

    load(fullfile(META_DIR, sprintf('ts_analysis_%s', sid)), 'repochs', 'tgts', 'rt');    
    load(fullfile(META_DIR, sprintf('%s_epochs', sid)), '*Dur');    

    % strip out everything but HG
    repochs = squeeze(repochs(5,:, :, :));
        
    %% now used a regularized classifier approach
%     s1 = RandStream.create('mrg32k3a','Seed', 50);
%     s0 = RandStream.setGlobalStream(s1);
%     
    labels = (double(tgts)==1)*2 - 1;    
    cp = cvpartition(labels,'k',N_FOLDS); % Stratified cross-validation
        
    estimates = zeros(size(repochs, 1), size(repochs, 3));
    posteriors = zeros(size(repochs, 1), size(repochs, 3));
    weights = false(size(repochs, 2), size(repochs, 3), N_FOLDS);
    
    repochs(isnan(repochs)) = 0;
    
    % for each time point
    for timei = 1:TIME_STEP:size(repochs, 3)
        if (rt(timei) < -preDur-.1 || rt(timei) > fbDur+.1)
            % do nothing
        else

            fprintf('  time %d of %d\n', timei, size(repochs, 3));

            features = repochs(:,:,timei);

            labels_hat = NaN*zeros(size(labels));
            probs = NaN*zeros(size(labels));
            
            % for each fold
            for n = 1:N_FOLDS
                tri = cp.training(n);
                tei = cp.test(n);

                % use lasso to select the features (cval)
    %             [B, Info] = lasso(features(tri, :), labels(tri), 'CV', 4);


                if (strcmp(METHOD, 'lasso'))
                    [B, Info] = lasso(features(tri, :), labels(tri), 'CV', 4, 'DFMax', 10, 'MCReps', 10);            
                    W = B(:, Info.IndexMinMSE);

                    if (sum(W~=0) == 0)
                        fprintf('!\n');
                        r2 = corr(features(tri, :), labels(tri)).^2;
                        [~, idx] = sort(r2, 'descend');                    
                        W(idx(1:3)) = 1;
                    end

                    weights(:, timei, n) = W;
                elseif (strcmp(METHOD, 'slda'))
                    error todo 
                end

                if (any(W))
                    % train a classifier & test on test data
                    % LDA / QDA
    %                 labels_hat(tei) = classify(features(tei, W~=0), features(tri, W~=0), labels(tri), 'quadratic');
                    % built-in SVM
    %                 svm = svmtrain(features(tri, W~=0), labels(tri));
    %                 labels_hat(tei) = svmclassify(svm, features(tei, W~=0));
                    % libsvm
                    svm = libsvmtrain(labels(tri), features(tri, W~=0), '-q -b 1 -t 0');
                    [labels_hat(tei), ~, mprobs] = libsvmpredict(labels(tei), features(tei, W~=0), svm, '-q -b 1');
                    probs(tei) = max(mprobs, [], 2);                
                end
            end

            posteriors(:, timei) = probs;            
            estimates(:, timei) = labels_hat;
        end
    end
    
    perf = mean(estimates == repmat(labels, [1 size(estimates, 2)]));
    
%     p = max(mean(tgts==1), 1 - mean(tgts==1));
    p = .5;
    [p50, lb, ub] = chanceBinom(p, length(tgts), 1000);
    
    figure
    plot(rt, perf, 'r', 'linew', 2);
    hold on;
    set(hline(p50, 'k'), 'linew', 2);
    hline([lb ub], 'k');
    
    set(vline([-preDur 0 fbDur], 'g:'), 'color', [.5 .5 .5]);
    xlim([-preDur fbDur]);
    
    xlabel('time (s)');
    ylabel('Classification Accuracy');
    
    title(sprintf('%d-fold instantaneous SVM - %s', N_FOLDS, sid));
    
    fname = sprintf('class_%s', sid);
    SaveFig(OUTPUT_DIR, fname, 'png', '-r600');
    SaveFig(OUTPUT_DIR, fname, 'eps', '-r600');
    
    save(fullfile(META_DIR, sprintf('class-%s', sid)), 'perf', 'estimates', 'posteriors', 'weights', 'N_FOLDS', 'p50', 'lb', 'ub', 'METHOD');
    
    allPerf{c} = perf;
end

%%
figure

plot(rt, mean(cat(1, allPerf{[1:6 8:11]}), 1))
hold on;
plot(rt, mean(cat(1, allPerf{[1:6 8:11]}), 1) + sem(cat(1, allPerf{[1:6 8:11]}), 1), ':')
legendOff(plot(rt, mean(cat(1, allPerf{[1:6 8:11]}), 1) - sem(cat(1, allPerf{[1:6 8:11]}), 1), ':'))

foo = cat(1, allPerf{[1:6 8:11]});
h = ttest(foo, .5, 'Alpha', 0.05);
plot(rt(h==1), 0.5*ones(size(find(h))), 'k.');

set(vline([-preDur 0 fbDur], ':'), 'color', [.5 .5 .5]);
xlim([-preDur fbDur]);

legend('Average', '+/- 1 sem', 'location', 'northwest');

title('Average Classification Performance (10 of 11 subjects)');
ylabel('Classification Accuracy');
xlabel('Time (s)');

fname = 'svm_all';
SaveFig(OUTPUT_DIR, fname, 'png', '-r600');
SaveFig(OUTPUT_DIR, fname, 'eps', '-r600');
