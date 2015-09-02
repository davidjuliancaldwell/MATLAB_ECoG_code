%%
Z_Constants;

CLEAR_OLD_FILES = true;

%%

for zid = SIDS
    sid = zid{:};
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject
    fprintf(' loading data: ');
    
    tic
    load(fullfile(META_DIR, [sid '_epochs']), 'paths', 'tgts', 'ress', 't', 'fbDur');
    load(fullfile(META_DIR, [sid '_behavior']), 'successProbabilities');
    toc

    ypaths = squeeze(paths(2, :, t > 0 & t <= fbDur));
    
    figure;
    for trial = 1:size(ypaths,1)
        cdata = successProbabilities{2}(trial, :);        
        a = 1:size(ypaths, 2);
        b = ypaths(trial,:); c = zeros(size(ypaths(trial,:)));
        if (tgts(trial)==1)
            b = 1-b;
        end
        surface([a;a],[b;b],[c;c], [cdata; cdata],...
            'facecol','no',...
            'edgecol','interp',...
            'linew',2);
        hold on;
    end
    
end