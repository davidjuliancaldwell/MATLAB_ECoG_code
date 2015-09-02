%% SETUP
Z_Constants;
addpath ./scripts;

%% perform analyses
biasMags = 0:0.01:1;

base = [.5 .5 .5 .5 .5 .5 .5 .49 .5 .495 .5];

acc = [];
dacc = [];

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    ifile = fullfile(META_DIR, [sid '_classification.mat']);
    load(ifile, 'estimates', 'posteriors');
    
    efile = fullfile(META_DIR, [sid '_epochs.mat']);
    load(efile, 'tgts', 'ress', 'endpoints');
    
    % a value for endpoint that is close to one means that the cursor ended
    % close to the bottom of the screen such that
    % 1 + (endpoints > .5) = ress
    
    if (any((1 + (endpoints' > base(sIdx))) ~= ress))
        error('assumption of .5 isn''t right');
    end
    
    tgts = toRow(tgts);
    ress = toRow(ress);
    endpoints = toRow(endpoints);
    
    % for pre / fb
    for periodi = 1:2
        est = toRow(estimates{periodi});
%         % hack, to make our estimates always correct
%         est = tgts==1;
        
        post = toRow(posteriors{periodi});
%         % hack to make them always confident
%         post = ones(size(post));
        
        for biasi = 1:length(biasMags)
            bias = biasMags(biasi);
            
            % if est == 1, upthresh < .5
            thresh = base(sIdx)*ones(size(endpoints));
            thresh2 = thresh - .5*bias*2*(post-.5).*(1-2*est);
          
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
%             
%             hold off;
            
            
            acc(sIdx, periodi, biasi) = mean(newres==tgts);
            dacc(sIdx, periodi, biasi) = mean(newres==tgts) - mean(ress==tgts);
            
%             newRess = endpoints 
        end
    end
    % for sweep bias values
    % determine new task performance
    
end


%% make figures
ci = linspace(.8, .2, size(dacc, 1))';
cols = cat(2, ones(size(ci)), ci, ci);

figure
for b = 1:2
    subplot(2,1,b);
    for c = 1:size(dacc, 1)
        d = squeeze(dacc(c,b,:));
        if (any(d > 0))
            linew = 1.5;
        else
            linew = 1;
        end
        legendOff(plot(biasMags, GaussianSmooth(d, 10), 'color', cols(c,:), 'linew', linew));
        hold on;
    end

    mu = squeeze(mean(dacc(:,b,:), 1));
    sig = squeeze(std(dacc(:,b,:), [], 1)) / sqrt(size(dacc, 1));
    
    plot(biasMags, mu, 'k', 'linew', 3);
    plot(biasMags, mu+sig, 'k--', 'linew', 3);
    plot(biasMags, mu-sig, 'k--', 'linew', 3);
    
    hline(0, 'k:');
    xlabel('Bias Magnitude (\alpha)');
    ylabel('Change in Accuracy');
    
    legend('mean', 'SEM', 'location', 'southwest');
    
    if (b==1)
        title('Targeting-phase biasing');
    else
        title('Feedback-phase biasing');
    end
end

set(gcf, 'pos', [624   128   672   850]);

SaveFig(OUTPUT_DIR, 'post_hoc_bias', 'eps');
SaveFig(OUTPUT_DIR, 'post_hoc_bias', 'png');
