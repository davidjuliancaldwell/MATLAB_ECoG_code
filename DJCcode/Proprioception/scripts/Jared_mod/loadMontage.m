%% function to open data and montage (or create a default montage if one does not already exist).
% Written by JDW, moved to function by JDO 08/2013

function [sig, sta, par, Montage] = loadMontage (filepath)

[~, ~, ext] = fileparts(filepath);

if (strcmp(ext, '.dat'))
    [sig, sta, par] = load_bcidat(filepath);
    sig = double(sig);
else
    load(filepath);
end

montageFilepath = strrep(filepath, '.dat', '_montage.mat');

if (exist(montageFilepath, 'file'))
    load(montageFilepath);
else
    % default Montage
    Montage.Montage = size(sig,2);
    Montage.MontageTokenized = {sprintf('Channel(1:%d)', size(sig,2))};
    Montage.MontageString = Montage.MontageTokenized{:};
    Montage.MontageTrodes = zeros(size(sig,2), 3);
    Montage.BadChannels = [];
    Montage.Default = true;
    fprintf ('\n existing montage not found, default montage created \n')
    Montage
end


