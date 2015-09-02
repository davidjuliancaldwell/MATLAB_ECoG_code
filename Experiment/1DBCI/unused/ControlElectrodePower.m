%% analysis looking at power changes in control electrode on subject by
%% subject basis

% common across all remote areas analysis scripts
subjects = {
    '04b3d5'
    '26cb98'
    '38e116'
    '4568f4'
    '30052b'
    'fc9643'
    'mg'
    };



for c = 1:length(subjects)
    load(['AllPower.m.cache\' subjects{c} '.mat']);

    up = 1;
    down = 2;

    % do stuff
    upes = epochZs(controlChannel, targetCodes == up);
    rs = restZs(controlChannel, :);
    
    [coeff, h] = signedSquaredXCorrValue(upes, rs, 2);
    [h2, p] = ttest2(upes, rs);

    fprintf('%s\tup\tr^2 = %f\t(p = %f, h1=%d, h2=%d)\n', subjects{c}, coeff, p, h, h2);
    
    downes = epochZs(controlChannel, targetCodes == down);
    
    [coeff, h] = signedSquaredXCorrValue(downes, rs, 2);
    [h2, p] = ttest2(downes, rs);
    
    fprintf('      \tdown\tr^2 = %f\t(p = %f, h1=%d, h2=%d)\n', coeff, p, h, h2);
    fprintf('\n');
    
    clearvars -except c subjects;
end

