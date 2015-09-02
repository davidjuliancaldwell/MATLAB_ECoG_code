%% 8/8/2014 - help from Miah on plotting from email 

% initialize a few things
subjid = '4568f4';
weights = randn(64,1);
Montage.MontageTokenized = {'Grid(1:64)'};
%% gets the electrode locations for this subject
% in their native brain space.
locs = trodeLocsFromMontage(subjid, Montage, false);
% now plot the weights on the subject specific brain. PlotDotsDirect has a
% bunch of input arguments
figure;
PlotDotsDirect(subjid, ... % the subject on who's brain the electrodes will be drawn
locs, ... % the location of the electrodes
weights, ... % the weights to use for coloring
'r', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
[-abs(max(weights)) abs(max(weights))], ... % the color limits for the weights
10, ... % the size of the dots, in points I believe
'recon_colormap', ... % the colormap to use for dot coloration
1:64, ... % labels for the electrodes, I think this can be a cell array 
true, ... % a boolean switch as to whether or not to draw the labels
false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
% calls to PlotDotsDirect where you don't want to keep
% re-drawing the brain over itself

% very often, after plotting the brain and dots, I add a colorbar for
% reference as to what the dot colors mean
load('recon_colormap'); % needs to be the same as what was used in the function call above
colormap(cm);
colorbar;

%% gets the electrode locations for this subject
% in TALAIRACH brain space, not the native
% subject space.
tlocs = trodeLocsFromMontage(subjid, Montage, true);
% now plot the weights on the talairach brain
PlotDotsDirect('tail', tlocs, weights, 'r', [-abs(max(weights)) abs(max(weights))], 10, 'recon_colormap', 1:64, true, false);
% very often, after plotting the brain and dots, I add a colorbar for
% reference as to what the dot colors mean
load('recon_colormap'); % needs to be the same as what was used in the function call above
colormap(cm);
colorbar;
%% so let's say we wanted to do this for a number of subjects
sids = {'fc9643', '4568f4', '0dd118'};
weights = randn(64,length(sids));
clims = [-abs(max(weights(:))) abs(max(weights(:)))]; % we want the color limits to be the same for all sets of dots
Montage.MontageTokenized = {'Grid(1:64)'};
for sIdx = 1:length(sids)
% get the electrode locations
    tlocs = trodeLocsFromMontage(sids{sIdx}, Montage, true);
% project them all to the right hemisphere, so we can see
% left-hemispheric coverage on the right side of the brain
    tlocs = projectToHemisphere(tlocs, 'r');
% a little bookkeeping so we don't replot the brain every time
    if (sIdx == 1)
       asOverlay = false;
    else
        asOverlay = true;
    end
    % and do the plotting.
    PlotDotsDirect('tail', tlocs, weights, 'r', clims, 10, 'recon_colormap', 1:64, true, asOverlay);
    pause; % let's pause so we can see this in action
end
% alternatively if you don't want to make a call to PlotDotsDirect every
% time in your loop, you can build up a list of weights and locations that
% accounts for all of the subjects and make one call to PlotDotsDirect at
% the end.
