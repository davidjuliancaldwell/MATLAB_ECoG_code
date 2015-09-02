%% define constants
addpath ./functions
Z_Constants;

%%

MAX_LAG_SEC = 1;
LAG_STEP_SAMPLES = 1;

DO_SIMULATIONS = 1;
DO_ACTUAL = 0;

RT_SEC = .5;

for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    fprintf ('processing %s: \n', subcode);
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)), 't', 'fs', '*Dur', 'diffs', 'targetY', 'targetD', 'paths', 'data', 'targets', 'cchan', 'hemi', 'montage', 'bad_channels');

    targetY = targetY';
    data = data';
    
    direction = cell(size(targetY));
    sz = cell(size(targetY));
    distance = cell(size(targetY));
    
    for e = 1:length(paths)
        % collect velocity and error
        
        
%         % look at data from the targeting period only
%         start = find(t >= -preDur + RT_SEC, 1, 'first');
%         endd = find(t < 0, 1, 'last');
  
%         % look at data from the feedback period only
%         start = find(t > 0 + RT_SEC, 1, 'first');
%         endd = min([find(t < maxFbDur, 1, 'last'), find(t < t(length(targetY{e}))-postDur, 1, 'last')]);

%         % look at data from the whole trial, excluding rest and post
%         start = find(t >= -preDur + RT_SEC, 1, 'first');
%         endd = min([find(t < maxFbDur, 1, 'last'), find(t < t(length(targetY{e}))-postDur, 1, 'last')]);

        % look at everything
        start = 1;
        endd = length(targetY{e});
        
        direction{e} = targetY{e}(start:endd) > .5; % up is 1, down is zero
        sz{e} = targetD{e}(start:endd) < 0.081; % large is 1, small is zero
        distance{e} = abs(targetY{e}(start:endd)-.5) > 0.21; % far is 1, near is zero
        
        for chan = 1:size(data, 2)
            if (ismember(chan, bad_channels))
                data{e, chan} = zeros(size(data{e, chan}(start:endd)));
            else
%                 temp = movingvar(GaussianSmooth(data{e, chan}, 15), 15);
%                 temp = movingvar(data{e, chan}, 15);
%                 data{e, chan} = temp(start:endd);

%                 data{e, chan} = GaussianSmooth(data{e, chan}(start:endd), round(fs*.500));

                  data{e, chan} = data{e, chan}(start:endd);
            end
        end
    end
    
%     return
%     
    mdata = mCell2mat(data);
%     for x = 1:64
figure
        prettyline(t, squeeze(mdata(:,cchan,:))', [cellfun(@(x) x(100), direction)]', 'br')
%         pause
%     end
    
    goodChannelIndicator = true(size(data, 2), 1);
    goodChannelIndicator(bad_channels) = false;
    
    % for each of the parameters of interest (just start with direction)
    % build and test a decoder

    estimateParameter(data(:, goodChannelIndicator), direction)
end
