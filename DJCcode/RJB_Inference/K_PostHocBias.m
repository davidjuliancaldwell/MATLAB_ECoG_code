%% SETUP
Z_Constants;
addpath ./scripts;

% TYPE = 'instantaneous';
TYPE = 'aggregate';

%% perform analyses

biasMags = 0:0.01:1;

base = [.5 .5 .5 .5 .5 .5 .5 .49 .5 .495 .5];

acc = zeros(length(SIDS), 69, length(biasMags));
dacc = acc;

acc_control = acc;
dacc_control = dacc;

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    
    if (strcmp(TYPE, 'aggregate'))
        load(fullfile(META_DIR, sprintf('class-agg-%s', sid)), 'estimates', 'posteriors','control_estimates','control_posteriors');
    else
        load(fullfile(META_DIR, sprintf('class-%s', sid)), 'estimates', 'posteriors','control_estimates','control_posteriors');
    end
    
    load(fullfile(META_DIR, sprintf('ts_analysis_%s', sid)), 'rt');    

    % convert estimates to target TYPEs
    estimates(estimates==-1) = 2;
    control_estimates(control_estimates==-1) = 2;
    
    efile = fullfile(META_DIR, [sid '_epochs.mat']);
    load(efile, 'tgts', 'ress', 'endpoints', '*Dur');

    % a value for endpoint that is close to one means that the cursor ended
    % close to the bottom of the screen such that
    % 1 + (endpoints > .5) = ress
    
    if (any((1 + (endpoints' > base(sIdx))) ~= ress))
        error('assumption of .5 isn''t right');
    end
    
    tgts = toRow(tgts);
    ress = toRow(ress);
    endpoints = toRow(endpoints);
    
    % do the actual experiment
    for timei = 1:size(estimates, 2)
        if (rt(timei) < -preDur-.1 || rt(timei) > fbDur+.1)
            % do nothing
        else
            est = toRow(estimates(:, timei));
    %         % hack, to make our estimates always correct
    %         est = tgts==1;

            post = toRow(posteriors(:, timei));
    %         % hack to make them always confident
    %         post = ones(size(post));

            for biasi = 1:length(biasMags)
                bias = biasMags(biasi);

                % if est == 1, upthresh < .5
                thresh = base(sIdx)*ones(size(endpoints));

                conf = 2*(post-.5);
                thresh2 = thresh + .5*bias*conf.*(3-2*est);
    %             thresh2 = thresh - .5*bias*conf.*est;

                newres = 1 + (endpoints > thresh2);            

    %             plot(thresh);
    %             hold all;
    %             plot(thresh2);
    %             plot(endpoints);
    %             hold on;
    %             x = find(tgts==ress);
    %             y = find(tgts==newres);
    %             plot(x, endpoints(x), 'rx');
    %             plot(y, endpoints(y), 'go');
    %             legend('thresh', 'thresh2', 'endpoints', 'orig hits', 'now hits');
    %             
    %             hold off;

                acc(sIdx, timei, biasi) = mean(newres==tgts);
                dacc(sIdx, timei, biasi) = (mean(newres==tgts) / mean(ress==tgts))-1;

    %             newRess = endpoints 
            end
        end
    end
    
    % do the control experiment
    for timei = 1:size(control_estimates, 2)
        if (rt(timei) < -preDur-.1 || rt(timei) > fbDur+.1)
            % do nothing
        else
            est = toRow(control_estimates(:, timei));
    %         % hack, to make our estimates always correct
    %         est = tgts==1;

            post = toRow(control_posteriors(:, timei));
    %         % hack to make them always confident
    %         post = ones(size(post));

            for biasi = 1:length(biasMags)
                bias = biasMags(biasi);

                % if est == 1, upthresh < .5
                thresh = base(sIdx)*ones(size(endpoints));

                conf = 2*(post-.5);
                thresh2 = thresh + .5*bias*conf.*(3-2*est);
    %             thresh2 = thresh - .5*bias*conf.*est;

                newres = 1 + (endpoints > thresh2);            

    %             plot(thresh);
    %             hold all;
    %             plot(thresh2);
    %             plot(endpoints);
    %             hold on;
    %             x = find(tgts==ress);
    %             y = find(tgts==newres);
    %             plot(x, endpoints(x), 'rx');
    %             plot(y, endpoints(y), 'go');
    %             legend('thresh', 'thresh2', 'endpoints', 'orig hits', 'now hits');
    %             
    %             hold off;

                control_acc(sIdx, timei, biasi) = mean(newres==tgts);
                control_dacc(sIdx, timei, biasi) = (mean(newres==tgts) / mean(ress==tgts))-1;

    %             newRess = endpoints 
            end
        end
    end    
end


%% make figures

comps = dacc([1:6 8:11], :, :);
smu = squeeze(mean(comps, 1));

figure

imagesc(rt, biasMags, smu');
axis xy;

set(gca, 'clim', [-.1 .1]);
% set(gca, 'clim', [-max(max(abs(smu))) max(max(abs(smu)))]);
axis xy
xlim([-2, 3])
load('america');
colormap(cm);

vline(0, 'k:');
xlabel('Time (s)');
ylabel('Bias Magnitude (\alpha)');
title(sprintf('Post-hoc trial biasing - %s', TYPE));

cb = colorbar;
set(get(cb,'ylabel'),'String', '% Change in performance');

if strcmp(TYPE, 'aggregate')
    tp = 'agg';
else
    tp = 'inst';
end

SaveFig(OUTPUT_DIR, sprintf('post_hoc_bias_%s', tp), 'eps');
SaveFig(OUTPUT_DIR, sprintf('post_hoc_bias_%s', tp), 'png');

%% make figures

control_comps = control_dacc([1:6 8:11], :, :);
control_smu = squeeze(mean(control_comps, 1));

figure

imagesc(rt, biasMags, control_smu');
axis xy;

set(gca, 'clim', [-.1 .1]);
% set(gca, 'clim', [-max(max(abs(smu))) max(max(abs(smu)))]);
axis xy
xlim([-2, 3])
load('america');
colormap(cm);

vline(0, 'k:');
xlabel('Time (s)');
ylabel('Bias Magnitude (\alpha)');
title(sprintf('Post-hoc trial biasing control - %s', TYPE));

cb = colorbar;
set(get(cb,'ylabel'),'String', '% Change in performance');

if strcmp(TYPE, 'aggregate')
    tp = 'agg';
else
    tp = 'inst';
end

SaveFig(OUTPUT_DIR, sprintf('post_hoc_bias_control_%s', tp), 'eps');
SaveFig(OUTPUT_DIR, sprintf('post_hoc_bias_control_%s', tp), 'png');

%% do averages by period
figure
plot(biasMags, max(smu(rt >= -1.5 & rt < 0, :),[],1), 'r', 'linew', 2)
% plot(biasMags, mean(smu(rt >= -1.5 & rt < 0, :),1 ), 'r', 'linew', 2)
hold on;
plot(biasMags, max(smu(rt >= 0 & rt <= 3, :),[], 1 ), 'b', 'linew', 2)
% plot(biasMags, mean(smu(rt >= 0 & rt <= 3, :),1 ), 'b', 'linew', 2)

plot(biasMags, max(control_smu(rt >= -1.5 & rt < 0, :),[],1), 'r:', 'linew', 2)
plot(biasMags, max(control_smu(rt >= 0 & rt <= 3, :),[], 1 ), 'b:', 'linew', 2)

ylabel('% Change in performance');
xlabel('Bias Magnitude(\alpha)');
ylim([-.1 .1]);
hline(0, 'k:');
legend('cue', 'feedback', 'cue control', 'feedback control', 'location', 'southwest');
title(sprintf('Post-hoc trial biasing - %s', TYPE));

SaveFig(OUTPUT_DIR, sprintf('post_hoc_bias_slice_%s', tp), 'eps');
SaveFig(OUTPUT_DIR, sprintf('post_hoc_bias_slice_%s', tp), 'png');


%% kick out some statistics

[val, alphai] = max(max(smu(rt >= -1.5 & rt < 0, :)));
fprintf('cue - peak average performance increase across all subjects %2.1f, alpha=%1.2f\n', val*100, biasMags(alphai));

[val, alphai] = max(max(smu(rt >= 0 & rt <= 3, :)));
fprintf('feedback - peak average performance increase across all subjects %2.1f, alpha=%1.2f\n', val*100, biasMags(alphai));
