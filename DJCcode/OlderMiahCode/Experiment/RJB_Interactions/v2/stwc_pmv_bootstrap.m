%     copyfile c:/users/administrator/documents/visual' Studio 2010'/Projects/gausswc/x64/Release/gausswc.mexw64 ./gausswc.mexw64;


%%
SIDS = {
    '30052b', ...
    '4568f4', ...
    '3745d1', ...
    '26cb98', ...
    'fc9643', ...
    '58411c', ...
    '0dd118', ...
    '7ee6bc', ...
    '38e116', ...
    'f83dbb', ...
};


%%

DO_XTRODE_HG = 1;
N = 500;

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    fprintf('working on %s\n', sid);
    
    fprintf('  loading data: '); tic;
    load(fullfile('meta', sprintf('%s_extracted.mat', sid)), 'c_hg', 'p_hg', 'trs', 't', 'fs', 'tgts', 'ress', '*Dur', 'cchan');
    load(fullfile('pmvdata_n150', sprintf('%s_epochs.mat', sid)), 'montage');
    toc;
    
    fprintf('estimated time completing this subject: %s\n', datestr(now+(5*(size(p_hg,1)*10/(1*24*60)))));
    
    % figure out which epochs are interesting
    half = true(size(tgts));
    half(ceil(length(half)/2):end) = 0;

    early = tgts == 1 & ress == 1 & half;
    late = tgts == 1 & ress == 1 & ~half;
    
    all = early + 2*late;
    
    keeper = all(all >= 1);
    earlies = keeper == 1;
    lates   = keeper == 2;
    
    all = all >= 1;
    
    c_hg = c_hg(:, all);
    
    % perform covariance analses
    winWidthSec = .500;
    winWidth = ceil(winWidthSec * fs);
    maxLagSec = .30;
    maxLag = ceil(maxLagSec * fs);
    lags = -maxLag:maxLag;

    windowFunction = single(ones(winWidth+1, 1));
    
    if (DO_XTRODE_HG)        
        %% cross-electrode hg interactions
        method = 'corr';
            
        allMax = zeros(size(p_hg, 1), N, 2);
        earlyMax = zeros(size(p_hg, 1), N, 2);
        lateMax = zeros(size(p_hg, 1), N, 2);
        allMin = zeros(size(p_hg, 1), N, 2);
        earlyMin = zeros(size(p_hg, 1), N, 2);
        lateMin = zeros(size(p_hg, 1), N, 2);

        tkeepi = t > -1 & t < 1;
        tkeepN = sum(tkeepi);
        tkeep = t(tkeepi);
        
        for chanIdx = 1:size(p_hg, 1)
            fprintf('  simulating cross electrode interactions (%d of %d): ', chanIdx, size(p_hg, 1)); tic    
            p_hg_temp = squeeze(p_hg(chanIdx, :, all));
                        
            for n = 1:N                
                interaction = zeros(2*maxLag + 1, tkeepN, size(c_hg, 2));
                
                for epochIdx = 1:size(c_hg, 2)
                    sc = scramblePhase(c_hg(:, epochIdx));
                    sp = scramblePhase(p_hg_temp(:, epochIdx));
                    
                    interaction(:, :, epochIdx) = gausswc(sc(tkeepi), sp(tkeepi), winWidth, maxLag, windowFunction, method);            
                end
                
                % figure out what the maximal interaction values were                
                intL = interaction;
                intT = interaction(:, tkeep > -0.5 & tkeep < 0.5, :);
                intLE = intL(:, :, earlies);
                intLL = intL(:, :, lates);
                intTE = intT(:, :, earlies);
                intTL = intT(:, :, lates);
                
                allMax(chanIdx, n, 1) = max(max(mean(intL, 3)));
                allMax(chanIdx, n, 2) = max(max(mean(intT, 3)));
                earlyMax(chanIdx, n, 1) = max(max(mean(intLE, 3)));
                earlyMax(chanIdx, n, 2) = max(max(mean(intTE, 3)));
                lateMax(chanIdx, n, 1) = max(max(mean(intLL, 3)));
                lateMax(chanIdx, n, 2) = max(max(mean(intTL, 3)));                                
                
                % minimal
                allMin(chanIdx, n, 1) = min(min(mean(intL, 3)));
                allMin(chanIdx, n, 2) = min(min(mean(intT, 3)));
                earlyMin(chanIdx, n, 1) = min(min(mean(intLE, 3)));
                earlyMin(chanIdx, n, 2) = min(min(mean(intTE, 3)));
                lateMin(chanIdx, n, 1) = min(min(mean(intLL, 3)));
                lateMin(chanIdx, n, 2) = min(min(mean(intTL, 3)));                                                
            end
            
            toc
        end
        
        datestr(now)
        save(fullfile('meta', [sid, '_simulations.mat']), 'method', 'N', 'earlies', 'lates', 'allMax', 'earlyMax', 'lateMax', 'allMin', 'earlyMin', 'lateMin', 't');
        
    end
end