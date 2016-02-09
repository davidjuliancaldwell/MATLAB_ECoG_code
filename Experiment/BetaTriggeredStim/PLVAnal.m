%% function to run in script to analyze PLV for channels of interest during beta stimulation - DJC 9-23-2015
% builds PLV chan, which is a matrix of the PLV values for each channel, m x n, each column is the given channel

function [PLVchan,PLVchanTrimmed] = PLVAnal(signalPLVmatrix)

Z_ConstantsPLV;

% enter the subject ID
sid = input('What is the subject ID? ','s');

freqs = input('What is the frequency range of interest? e.g. 12-25 ','s');

state = input('Pre or Post? ','s');

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

% build a PLV matrix
PLVchan = zeros(size(signalPLVmatrix));

for chan = 1:size(signalPLVmatrix)
    
    %% extract PLVs
    PLVtemp = signalPLVmatrix((1:chan),chan);
    PLVtemp = horzcat(PLVtemp',(signalPLVmatrix(chan,(chan+1:end))));
    
    % set the PLV value at the channel to be NaN as to not confuse the data
    %
    PLVtemp(chan) = nan;
    
    PLVchan(:,chan) = PLVtemp;
    
end

% ask for channels of interest
chansInt = input('What channels are of interest? List as matrix e.g. [1 2 3] ');

% ask for what electrodes are of interest for plotting, if just grid, 1:64 for instance
electrodes = input('What electrodes are of interest for plotting? e.g. [1:64] ');

PLVchanTrimmed = PLVchan(electrodes,electrodes);

%% extract the PLV of the channel of interest, make a bar graph, plot it on the brain, etc

for chan = chansInt
    %% make bar graph of PLV values
    
    figure
    bar(PLVchan(:,chan))
    title(sprintf('%s stim PLV values for %s Hz for Channel %d',state,freqs,chan));
    xlabel('Channel Number');
    ylabel('PLV value');
    ylim([0 1]);
    
    SaveFig(OUTPUT_DIR, sprintf(['PLVbar-%s-chan%d-%s'], sid, chan, state), 'eps', '-r600');
    SaveFig(OUTPUT_DIR, sprintf(['PLVbar-%s-chan%d-%s'], sid, chan, state), 'png', '-r600');
    
    %% plot it on the brain
    
    % now plot the weights on the subject specific brain. PlotDotsDirect has a
    % bunch of input arguments
    figure;
    
    clims = [0 1];
    PlotDotsDirect(sid, ... % the subject on who's brain the electrodes will be drawn
        locs, ... % the location of the electrodes
        PLVchanTrimmed(:,chan), ... % the weights to use for coloring
        'l', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
        clims, ... % the color limits for the weights
        15, ... % the size of the dots, in points I believe
        'recon_colormap', ... % the colormap to use for dot coloration
        1:length(PLVchanTrimmed), ... % labels for the electrodes, I think this can be a cell array
        true, ... % a boolean switch as to whether or not to draw the labels
        false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
    % calls to PlotDotsDirect where you don't want to keep
    % re-drawing the brain over itself
    
    % very often, after plotting the brain and dots, I add a colorbar for
    % reference as to what the dot colors mean
    load('recon_colormap'); % needs to be the same as what was used in the function call above
    colormap(cm);
    colorbar;
    title(sprintf('%s stim PLV values for %s Hz for Channel %d',state,freqs,chan))
    
%     SaveFig(OUTPUT_DIR, sprintf(['PLVbrain-%s-chan%d-%s'], sid, chan, state), 'eps', '-r300');
%     SaveFig(OUTPUT_DIR, sprintf(['PLVbrain-%s-chan%d-%s'], sid, chan, state), 'png', '-r300');
%     
    
end

end
