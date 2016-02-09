%% this is a function that you input PLV values for a channel in two different states, for example, pre and post
function [diffs] = PLVAnalDifs(PLVpre,PLVpost)

Z_ConstantsPLV;

% enter the subject ID
sid = input('What is the subject ID? ','s');

freqs = input('What is the frequency range of interest? e.g. 12-25 ','s');

%get brain info

switch(sid)
    case 'ecb43e'
        
        % this is for ecb43e
        
        %there appears to be no montage for this subject currently
        Montage.Montage = 64;
        Montage.MontageTokenized = {'Grid(1:64)'};
        Montage.MontageString = Montage.MontageTokenized{:};
        Montage.MontageTrodes = zeros(64, 3);
        Montage.BadChannels = [];
        Montage.Default = true;
        
        % get electrode locations
        locs = trodeLocsFromMontage(sid, Montage, false);
    case '0b5a2e'
        
        % this is for ecb43e
        
        %there appears to be no montage for this subject currently
        Montage.Montage = 64;
        Montage.MontageTokenized = {'Grid(1:64)'};
        Montage.MontageString = Montage.MontageTokenized{:};
        Montage.MontageTrodes = zeros(64, 3);
        Montage.BadChannels = [];
        Montage.Default = true;
        
        % get electrode locations
        locs = trodeLocsFromMontage(sid, Montage, false);
end

% ask for channels of interest
chansInt = input('What channels are of interest? List as matrix e.g. [1 2 3] ');

% ask for what electrodes are of interest for plotting, if just grid, 1:64 for instance
electrodes = input('What electrodes are of interest for plotting? e.g. [1:64] ');

%% difference between Pre and Post conditions for channels of interest

%added in for channel to exclude 10-19-2015 DJC
%
badChans = input('What are the bad channels?');

diffs = PLVpost - PLVpre;
for bad = badChans
    diffs(bad,:) = NaN;
    
end


for chan = chansInt
    
    % bar graph of differences
    figure
    bar(diffs(:,chan))
    title(sprintf('PLV differences between post and pre rest states for %s Hz in relation to Channel %d',freqs,chan))
    xlabel('Channel Number')
    ylabel('PLV value Difference')
    
    figure;
    
    clims = [min(diffs(:,chan)),max(diffs(:,chan))];
    PlotDotsDirect(sid, ... % the subject on who's brain the electrodes will be drawn
        locs, ... % the location of the electrodes
        diffs(:,chan), ... % the weights to use for coloring
        'l', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
        clims, ... % the color limits for the weights
        15, ... % the size of the dots, in points I believe
        'recon_colormap', ... % the colormap to use for dot coloration
        1:length(diffs), ... % labels for the electrodes, I think this can be a cell array
        true, ... % a boolean switch as to whether or not to draw the labels
        false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
    % calls to PlotDotsDirect where you don't want to keep
    % re-drawing the brain over itself
    
    % very often, after plotting the brain and dots, I add a colorbar for
    % reference as to what the dot colors mean
    load('recon_colormap'); % needs to be the same as what was used in the function call above
    colormap(cm);
    colorbar;
    title(sprintf('Difference between Post and pre stim PLV values for %s Hz for Channel %d',freqs,chan))
end

% %% channels of interest around 55 (which is the beta recording channel)
% chansInt = [48,39,47,55,63,62,54,46];
% diffsInt = diffs(chansInt);
%
% stimsInt = [56 64];
% diffsStim = diffs(stimsInt);

end