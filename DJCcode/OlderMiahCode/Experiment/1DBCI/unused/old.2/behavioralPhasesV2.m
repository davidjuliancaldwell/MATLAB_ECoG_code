% behavioral Analysis

% load ds/26cb98_ud_im_t_ds.mat
% load ds/38e116_ud_mot_h_ds.mat
% load ds/4568f4_ud_mot_t_ds.mat
load ds/30052b_ud_im_t_ds.mat
% load ds/fc9643_ud_mot_t_ds.mat

pathsNorm = [];
targets = [];

for recnum = 1:length(ds.recs)
    [signals, states, parameters] = load_bcidat([ds.recs(recnum).dir '\' ds.recs(recnum).file]);
    load([ds.recs(recnum).dir '\' ds.recs(recnum).montage]);
    
    parameters = CleanBCI2000ParamStruct(parameters);

    cpy = fixYPos(states.CursorPosY);
    height = double(parameters.WindowHeight);
    fb = double(states.Feedback);

    yPath = max(min(cpy, height), 0);
    yPathNorm = yPath / height;

    fbEvents = [0; diff(fb)];
    fbOnset = find(fbEvents == 1);
    fbOffset = find(fbEvents == -1);
    
    if length(fbOnset) > length(fbOffset)
        fbOnset = fbOnset(1:length(fbOffset));
    end
    parameters.SamplingRate
    parameters.FeedbackDuration
    
    pathT = (0:(fbOffset(1)-fbOnset(1)-1))'/parameters.SamplingRate;
    
    for c = 1:length(fbOnset)
        pathsNorm = [pathsNorm yPathNorm(fbOnset(c):(fbOffset(c)-1))]; 
    end
    
    targets = [targets; states.TargetCode(fbOnset)];    
end

values = zeros(size(targets));
for idx = 1:length(targets)
    target = targets(idx);
    
    if (target == 1)
        temp = pathsNorm(:,idx) < 0.5;
        values(idx) = sum(double(temp)) / length(temp);
    else
        temp = pathsNorm(:,idx) > 0.5;
        values(idx) = sum(double(temp)) / length(temp);
    end
end

figure, plot(values, 'r*');
hold on;
plot(WindowedAverage(values, 10), 'k');

