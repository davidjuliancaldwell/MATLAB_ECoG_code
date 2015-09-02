function rs = FTScreen(ds, doPlots)

    if (nargin < 2)
        doPlots = true;
    end
    
    if (~isstruct(ds))
        error('FTScreen works on dataset structs, check your arguments.');
    end
    
    for recNum = 1:length(ds.recs)
        rs.results(recNum) = processRecording(ds.recs(recNum));
    end; clear recNum;
    
    if (doPlots == true)
        showResults(ds, rs);
    end
end

function result = processRecording(rec)
    % set up the bad result
    bad.rsaValues = [];
    
    path = [rec.dir '\' rec.file];
    if (~exist(path, 'file'))
        warning('target recording file does not exist: %s\n', path);
        result = bad;
        return;
    end
    
    % load in the signal
    
    delay = 600;
    
    switch (rec.type)
        case 'bci2k'
            [sig, sta, par] = load_bcidat(path);
            
            signals = double(sig);
            
            code = sta.StimulusCode;
%             switch(rec.trigger)
%                 case 'glove'
%                     glove = getGlove(sta);
%                     delay = 0;
%                 case 'stimulus'
%                     glove = [];
%                 otherwise
%                     warning ('tried to process unrecognized trigger type: %s Skipping recording\n', rec.trigger);
%                     result = bad;
%                     return;
%             end
                        
            fs = par.SamplingRate.NumericValue;
            gugers = isfield(par,'CommonReference');
            
            montagePath = strrep(path, '.dat', '_montage.mat');
            load(montagePath);
            
        case 'clinical'
            load(path);
            gugers = false;
            
%             glove = [];
            
            % should contain: signals, feedback, targetCode, resultCode, fs
            if (~exist('signals', 'var') || ~exist('code', 'var') || ~exist('fs', 'var') || ~exist('Montage', 'var'))
                warning('clinical recording file, not formatted correctly for recording: %d.  Skipping file\n', path);
                result = bad;
                return;
            end
        otherwise
            warning('tried to process unrecognized recording type: %s.  Skipping file\n', rec.type);
            result = bad;
            return;
    end
       
    % process the signal    
    if (~gugers)
        fprintf('Non Guger detected\n');
        signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
    else
        fprintf('Guger detected! Re-referencing each amplifier bank together...\n'); 
        signals = ReferenceCAR([16 16 16 16], Montage.BadChannels, signals);
    end
 
    powers = hilbAmp(signals, [70 200], fs).^2;
    
    code = double(code);
    
    
    epochs = ones(length(find(diff(code)~= 0)),1);
    epochs(:,1) = cumsum(epochs(:,1));
    newEpochAt = find(diff(code) ~= 0);
    epochs(:,2:3) = [newEpochAt+1 [newEpochAt(2:end);length(code)]];
    epochs(:,4) = code(epochs(:,3));
        
    switch(rec.trigger)
        case 'stimulus'
            % do nothing
        case 'glove'
            temp = epochs; % TODO delete
            
            [offsets, gchan] = identifyGloveMotion(sta, par, 22, fs, [-600 2400], [-300 300], rec.activity, 'onset', 0.2);
            idxs = ismember(epochs(:,4), rec.activity);
            
%             diffs = offsets - epochs(idxs,2);
            epochs(idxs,2) = offsets;
%             epochs(idxs,3) = epochs(idxs,3) + diffs;
            epochs(idxs,3) = offsets + fs;
            delay = 0;
    end
    
    meanPowers = zeros(size(epochs,1), size(signals, 2));
    
    for epoch = epochs'
        range = epoch(2):epoch(3);
        range = range + delay;
        
        range = range(range < size(signals, 1));
        
        meanPowers(epoch(1),:) = mean(powers(range,:));
    end
    
    result.rsaValues = zeros(size(signals,2),1);

    actPeriods = meanPowers(ismember(epochs(:,4), rec.activity),:);
    restPeriods = meanPowers(epochs(:,4) == rec.rest,:);

    % note, this RSA calc should probably be its own function
    numerator = ((mean(actPeriods,1)-mean(restPeriods,1)).^3);
    dena = abs(mean(actPeriods,1)-mean(restPeriods,1));
    denb = var([actPeriods;restPeriods],1);
    num2 = (size(actPeriods,1)*size(restPeriods,1));
    den2 = size([actPeriods;restPeriods],1);

    result.rsaValues=numerator./(dena.*denb).*num2./den2.^2;        
    result.rsaValues(Montage.BadChannels) = NaN;
    
end

function showResults(ds, rs)
    load([ds.surf.dir '\' ds.surf.file]);
    load([ds.trodes.dir '\' ds.trodes.file]);

%     figure;
    resCount = length(rs.results);
    for resNum = 1:resCount
%         if (resCount < 3)
%             subplot(resCount, 1, resNum);
%         else
%             subplot(ceil(sqrt(resCount)), ceil(sqrt(resCount)), resNum);
%         end
        
%         ctmr_gauss_plot(cortex, Grid, rs.results(resNum).rsaValues, 'r', [-1 1]);
%         PlotWeightedElectrodes(cortex, Grid, rs.results(resNum).rsaValues, 'r', [.5 .5 .5], [1 0 0], 40); 
        ctmr_dot_plot(cortex, Grid, rs.results(resNum).rsaValues, 'r', [-1 1], 20);

        % highlight the stim trodes
        plot3(Grid(ds.stimTrodes,1),Grid(ds.stimTrodes,2),Grid(ds.stimTrodes,3),'o','Color','y','MarkerSize', 21);
        
        title(ds.recs(resNum).name);
        colorbar;
        
    end
    
    figTitle = [ds.subjId ' finger twister HG RSA Analysis - All activity vs Rest'];
    maximize(gcf);
    set(gcf, 'Name', figTitle);        
    mtit(figTitle, 'xoff', 0, 'yoff', 0.05);    
end