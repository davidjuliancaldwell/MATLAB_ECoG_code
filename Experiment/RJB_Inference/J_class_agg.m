Z_Constants;

addpath ./scripts;


N_FOLDS = 10;
TIME_STEP = 1;

METHOD = 'lasso';
N_REPS = 10;

% METHOD = 'mRMR';
% N_FEATURES = 10;

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
     
    labels = (double(tgts)==1)*2 - 1;    
    cp = cvpartition(labels,'k',N_FOLDS); % Stratified cross-validation
        
    estimates = zeros(size(repochs, 1), size(repochs, 3));
    posteriors = zeros(size(repochs, 1), size(repochs, 3));
%     weights = cell(size(repochs, 2), size(repochs, 3), N_FOLDS);

    control_estimates = estimates;
    control_posteriors = estimates;
    control_labels = shuffle(labels);
    
    % do the actual experiment
    % for each time point
    repochs(isnan(repochs)) = 0;
    rfeatures = cell(N_FOLDS, 1);
    
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
                mfeatures = cat(2, rfeatures{n}, features);

                tri = cp.training(n);
                tei = cp.test(n);

                % use lasso to select the features (cval)
    %             [B, Info] = lasso(features(tri, :), labels(tri), 'CV', 4);


                if (strcmp(METHOD, 'lasso'))
                    [B, Info] = lasso(mfeatures(tri, :), labels(tri), 'CV', 4, 'DFMax', 10, 'MCReps', N_REPS);            
                    W = B(:, Info.IndexMinMSE);

                    if (sum(W~=0) == 0)
                        fprintf('!\n');
                        r2 = corr(mfeatures(tri, :), labels(tri)).^2;
                        [~, idx] = sort(r2, 'descend');                    
                        W(idx(1:3)) = 1;
                    else
                        rfeatures{n} = mfeatures(:, W~=0);        
                    end            

    %                 weights{timei, n} = W;
                
                elseif (strcmp(METHOD, 'mRMR'))
                    feats = mrmr_corrq_d(mfeatures(tri, :), labels(tri), N_FEATURES);
                    W = zeros(size(mfeatures, 2), 1);
                    W(feats) = 1;
                         
                    rfeatures{n} = mfeatures(:, W~=0);        
                    
                elseif (strcmp(METHOD, 'slda'))
                    error todo 
                end

                if (any(W))
                    % train a classifier & test on test data
                    % LDA / QDA
    %                 labels_hat(tei) = classify(mfeatures(tei, W~=0), mfeatures(tri, W~=0), labels(tri), 'quadratic');
                    % built-in SVM
    %                 svm = svmtrain(mfeatures(tri, W~=0), labels(tri));
    %                 labels_hat(tei) = svmclassify(svm, mfeatures(tei, W~=0));
                    % libsvm
                    svm = libsvmtrain(labels(tri), mfeatures(tri, W~=0), '-q -b 1 -t 0');
                    [labels_hat(tei), ~, mprobs] = libsvmpredict(labels(tei), mfeatures(tei, W~=0), svm, '-q -b 1');
                    probs(tei) = max(mprobs, [], 2);                
                end            
            end

            posteriors(:, timei) = probs;
            estimates(:, timei) = labels_hat;
        end
    end
    
    % do the control experiment
    % for each time point
    repochs(isnan(repochs)) = 0;
    rfeatures = cell(N_FOLDS, 1);
    
    for timei = 1:TIME_STEP:size(repochs, 3)
        if (rt(timei) < -preDur-.1 || rt(timei) > fbDur+.1)
            % do nothing
        else
            fprintf('  time %d of %d\n', timei, size(repochs, 3));

            features = repochs(:,:,timei);

            labels_hat = NaN*zeros(size(control_labels));
            probs = NaN*zeros(size(control_labels));

            % for each fold
            for n = 1:N_FOLDS
                mfeatures = cat(2, rfeatures{n}, features);

                tri = cp.training(n);
                tei = cp.test(n);

                % use lasso to select the features (cval)
    %             [B, Info] = lasso(features(tri, :), labels(tri), 'CV', 4);


                if (strcmp(METHOD, 'lasso'))
                    [B, Info] = lasso(mfeatures(tri, :), control_labels(tri), 'CV', 4, 'DFMax', 10, 'MCReps', N_REPS);            
                    W = B(:, Info.IndexMinMSE);

                    if (sum(W~=0) == 0)
                        fprintf('!\n');
                        r2 = corr(mfeatures(tri, :), control_labels(tri)).^2;
                        [~, idx] = sort(r2, 'descend');                    
                        W(idx(1:3)) = 1;
                    else
                        rfeatures{n} = mfeatures(:, W~=0);        
                    end            

    %                 weights{timei, n} = W;
                
                elseif (strcmp(METHOD, 'mRMR'))
                    feats = mrmr_corrq_d(mfeatures(tri, :), control_labels(tri), N_FEATURES);
                    W = zeros(size(mfeatures, 2), 1);
                    W(feats) = 1;
                          
                    rfeatures{n} = mfeatures(:, W~=0);
                    
                elseif (strcmp(METHOD, 'slda'))
                    error todo 
                end

                if (any(W))
                    % train a classifier & test on test data
                    % LDA / QDA
    %                 labels_hat(tei) = classify(mfeatures(tei, W~=0), mfeatures(tri, W~=0), labels(tri), 'quadratic');
                    % built-in SVM
    %                 svm = svmtrain(mfeatures(tri, W~=0), labels(tri));
    %                 labels_hat(tei) = svmclassify(svm, mfeatures(tei, W~=0));
                    % libsvm
                    svm = libsvmtrain(control_labels(tri), mfeatures(tri, W~=0), '-q -b 1 -t 0');
                    [labels_hat(tei), ~, mprobs] = libsvmpredict(control_labels(tei), mfeatures(tei, W~=0), svm, '-q -b 1');
                    probs(tei) = max(mprobs, [], 2);                
                end            
            end

            control_posteriors(:, timei) = probs;
            control_estimates(:, timei) = labels_hat;
        end        
    end
    
    perf = mean(estimates == repmat(labels, [1 size(estimates, 2)]));
    control_perf = mean(control_estimates == repmat(control_labels, [1 size(control_estimates, 2)]));
    
%     p = max(mean(tgts==1), 1 - mean(tgts==1));
    p = .5;
    [p50, lb, ub] = chanceBinom(p, length(tgts), 1000);
    
    figure
    plot(rt, perf, 'r', 'linew', 2);
    hold on;
    plot(rt, control_perf, 'b', 'linew', 2);
    
    legend('actual', 'control');
    
    set(hline(p50, 'k'), 'linew', 2);
    hline([lb ub], 'k');
    
    set(vline([-preDur 0 fbDur], 'g:'), 'color', [.5 .5 .5]);
    xlim([-preDur fbDur]);
    
    xlabel('time (s)');
    ylabel('Classification Accuracy');
    
    title(sprintf('%d-fold aggregate SVM - %s', N_FOLDS, sid));
    
    fname = sprintf('class_agg_%s', sid);
    SaveFig(OUTPUT_DIR, fname, 'png', '-r600');
    SaveFig(OUTPUT_DIR, fname, 'eps', '-r600');
    
    save(fullfile(META_DIR, sprintf('class-agg-%s', sid)), 'perf', 'labels', 'estimates', 'posteriors', 'control_labels', 'control_perf', 'control_estimates', 'control_posteriors', 'N_FOLDS', 'p50', 'lb', 'ub', 'METHOD');
    
    allPerf{c} = perf;
    allControlPerf{c} = control_perf;
end

%%
figure

plot(rt, mean(cat(1, allPerf{[1:6 8:11]}), 1), 'r', 'linew', 2)
hold on;
plot(rt, mean(cat(1, allPerf{[1:6 8:11]}), 1) + sem(cat(1, allPerf{[1:6 8:11]}), 1), 'r:')
legendOff(plot(rt, mean(cat(1, allPerf{[1:6 8:11]}), 1) - sem(cat(1, allPerf{[1:6 8:11]}), 1), 'r:'))

plot(rt, mean(cat(1, allControlPerf{[1:6 8:11]}), 1), 'b', 'linew', 2)
plot(rt, mean(cat(1, allControlPerf{[1:6 8:11]}), 1) + sem(cat(1, allControlPerf{[1:6 8:11]}), 1), 'b:')
legendOff(plot(rt, mean(cat(1, allControlPerf{[1:6 8:11]}), 1) - sem(cat(1, allControlPerf{[1:6 8:11]}), 1), 'b:'))

actualSig = cat(1, allPerf{[1:6 8:11]});
controlSig = cat(1, allControlPerf{[1:6 8:11]});
[h, p] = ttest(actualSig, controlSig, 'Alpha', 0.05, 'Dim', 1);
[p_thresh] = fdr(p(~isnan(p))', 0.05);

h = p<=p_thresh;
plot(rt(h==1), 0.3*ones(size(find(h))), 'k.');

set(vline([-preDur 0 fbDur], ':'), 'color', [.5 .5 .5]);
xlim([-preDur fbDur]);

yl = ylim;
ylim([0 yl(2)]);
    
legend('Actial', '+/- 1 sem', 'Control', '+/- 1 sem', 'location', 'southwest');

title('Average Classification Performance (10 of 11 subjects)');
ylabel('Classification Accuracy');
xlabel('Time (s)');

fname = 'svm_agg_all';
SaveFig(OUTPUT_DIR, fname, 'png', '-r600');
SaveFig(OUTPUT_DIR, fname, 'eps', '-r600');

%% spit out some stats
for c = 1:length(SIDS)
    sid = SIDS{c};
    load(fullfile(META_DIR, sprintf('class-agg-%s', sid)), 'perf', 'control_perf');
    
    allPerf{c} = perf;
    allControlPerf{c} = control_perf;
end

actual = cat(1, allPerf{[1:6 8:11]});
actual_cue = mean(actual(:, rt > -1.5 & rt <= 0), 2);
actual_fb = mean(actual(:, rt > 0.5 & rt <= 3), 2);

control = cat(1, allControlPerf{[1:6 8:11]});
control_cue = mean(control(:, rt > -1.5 & rt <= 0), 2);
control_fb = mean(control(:, rt > 0.5 & rt <= 3), 2);

fprintf('actual: %2.1f +/- %2.1f pct (cue); %2.1f +/- %2.1f pct (fb)\n', mean(actual_cue)*100, sem(actual_cue)*100, mean(actual_fb)*100, sem(actual_fb)*100);
fprintf('control: %2.1f +/- %2.1f pct (cue); %2.1f +/- %2.1f pct (fb)\n', mean(control_cue)*100, sem(control_cue)*100, mean(control_fb)*100, sem(control_fb)*100);

[h,p] = ttest(actual_cue, control_cue)
[h,p] = ttest(actual_fb, control_fb)