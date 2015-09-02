%% this script is used to generate many reiterations of a given BCI2000
%% recording, using randomly generated states as opposed to the old ones

%% first, generate a list of all BCI2000 recordings that we could use
dsFile{1} = fullfile('metadata', 'ds', '26cb98_ud_im_t_ds.mat');
dsFile{2} = fullfile('metadata', 'ds', '38e116_ud_mot_h_ds.mat');
dsFile{3} = fullfile('metadata', 'ds', '4568f4_ud_mot_t_ds.mat');
dsFile{4} = fullfile('metadata', 'ds', '30052b_ud_im_t_ds.mat');
dsFile{5} = fullfile('metadata', 'ds', 'fc9643_ud_mot_t_ds.mat');
dsFile{6} = fullfile('metadata', 'ds', 'mg_ud_im_t_ds.mat');
dsFile{7} = fullfile('metadata', 'ds', '04b3d5_ud_im_t_ds.mat');

files = {};

for c = 1:length(dsFile)
   load(dsFile{c});
   
   for recNum = 1:length(ds.recs)
       files = cat(1, files, fullfile(ds.recs(recNum).dir, ds.recs(recNum).file));
   end
end


%% launch the fileplayback/arsignalprocessing/feedbackdemo bci2000 stack
system('d:\research\code\bci2k_current\batch\FeedbackDemo_FilePlayback.bat');
pause(3); % wait for everything to come up

%% make a random list of recordings
numFilesToConsider = 20;
fileIdxs = randi(length(files), numFilesToConsider, 1);
filesToConsider = files(fileIdxs);

odir = fullfile(myGetenv('output_dir'), '1DBCI');

TouchDir(fullfile(odir, 'replay'));
TouchDir(fullfile(odir, 'replay','parms'));
TouchDir(fullfile(odir, 'replay', 'input'));

%% generate a parameter file for that recording, along with the necessary
% changes to make it work with fileplayback
parFiles = {};

for c = 1:numFilesToConsider
    file = filesToConsider{c};
    
    [signals,states,parameters] = load_bcidat(file);
    
    % phase scramble the ecog and write it back out
    signals = replayRandomizeSignal(double(signals));
    
    odatfile = strrep(file, myGetenv('subject_dir'), fullfile(odir, 'replay', 'input'));
    TouchDir(fileparts(odatfile));
    save_bcidat(odatfile, signals, states, parameters);
    
    parameters.WindowLeft.NumericValue = 0;
    parameters.DataDirectory.Value = {fullfile(odir, 'replay', 'data')};
    parameters.SubjectName.Value = {'replay'};
    partext = convert_bciprm(parameters);
    
    ofile = strrep(file, '.dat', '.prm');
    [~, name, ext] = fileparts(ofile);
    ofile = fullfile(odir, 'replay', 'parms', [name ext]);
    parFiles{c} = ofile;
    
    fprintf('  writing %s\n', ofile);
    
    if (exist(ofile, 'file'))
        delete(ofile);
    end

    fhandle = fopen(ofile, 'w');

    partext{end+1} = sprintf('Source:Playback:FilePlaybackADC string PlaybackFileName= %s // the path to the existing BCI2000 data file (inputfile)', odatfile);
    partext{end+1} = sprintf('Source:Playback:FilePlaybackADC int PlaybackStates= 0 0 0 1 // play back state variable values (except timestamps)? (boolean)');
    partext{end+1} = sprintf('Source:Playback:FilePlaybackADC float PlaybackSpeed= 8 1 0 100 // a value indicating the factor by which the acquisition should be sped up');
   partext{end+1} = sprintf('Source:Playback:FilePlaybackADC int PlaybackLooped= 1 0 0 1 // loop playback at the end of the data file instead of suspending execution (boolean)');

    
    for c2 = 1:length(partext)
        if (~isempty(strfind(partext{c2}, 'Expressions')))
            partext{c2} = 'Filtering:ExpressionFilter matrix Expressions= 0 1 // expressions used to compute the output of the ExpressionFilter (rows are channels; empty matrix for none)';
        end
        
        fprintf(fhandle, '%s\n',partext{c2});
    end
    
    fclose(fhandle);
end

%% load the parameter file and execute the run
% cycling through all of the files to consider above, load the
% corresponding parameter file in to BCI2000

% open a coms line to BCI2000
t = tcpip('127.0.0.1', 3999);

% resp = t.read();
% c = 1;
% 
% while(length(resp) > 0)
%     resp = t.read();
%     if c > 100
%         warning('endless loop');
%         break;
%     else
%         c = c+1;
%     end
% end

repcount = 5;

for c = 1:numFilesToConsider
    parFile = parFiles{c};
    
    % load the parameter file
    cmd = sprintf('LOAD PARAMETERFILE %s', parFile);
    t.write(cmd);
    pause(1);

%     % set the configuration
%     cmd = 'SETCONFIG';
%     t.write(cmd);
%     pause(1);
    
    for d = 1:repcount
        % for each execution to be run, set the PlaybackStartTime parameter to
        % something uniformly distributed between 0s and 3s
        time = [num2str(randi(7,1)) 's']
        cmd = sprintf('SET PlaybackStartTime %s', time);
        t.write(cmd);
        pause(.5);

        % set the configuration
        cmd = 'SETCONFIG';
        t.write(cmd);
        pause(.5);
        
        % start BCI2000
        cmd = 'START';
        t.write(cmd);
        pause(2);

        % poll BCI2000 for a finish signal?
        cmd = 'GET SYSTEM STATE';
        t.write(cmd);
        resp = t.read();
        warning(resp);
        while (isempty(strfind(resp, 'Suspended')))
            pause(1);
            if(~(isempty(strfind(resp, 'Resting'))))
                t.write('START');
                pause(2);
            else
                t.write(cmd);
                resp = t.read();
                warning(resp);
            end
        end
        fprintf('run complete\n\n\n');
        
        pause(1);
    end
end

t.write('QUIT');
%     
% % %% verify this worked right
% % prefiles = filesToConsider;
% % postfiles = {'d:\research\code\gridlab\Experiment\1DBCI\replay\data\replay001\replayS001R01.dat',...
% %     'd:\research\code\gridlab\Experiment\1DBCI\replay\data\replay001\replayS001R02.dat',...
% %     'd:\research\code\gridlab\Experiment\1DBCI\replay\data\replay001\replayS001R03.dat',...
% %     'd:\research\code\gridlab\Experiment\1DBCI\replay\data\replay001\replayS001R04.dat',...
% %     'd:\research\code\gridlab\Experiment\1DBCI\replay\data\replay001\replayS001R05.dat'};
% % 
% % for c = 1:5
% %     [sig, sta, ~] = load_bcidat(prefiles{c});
% %     [sig2, sta2, ~] = load_bcidat(postfiles{c});
% %     
% %     figure;
% %     subplot(211);
% %     plot(zscore(double(sig(:,1))),'b');
% %     hold on;
% %     plot(sta.TargetCode, 'g');
% %     plot(sta.ResultCode, 'r:');
% %     
% %     subplot(212);
% %     plot(zscore(double(sig2(:,1))),'b');
% %     hold on;
% %     plot(sta2.TargetCode, 'g');
% %     plot(sta2.ResultCode, 'r:');
% %     
% %     pause
% % end

%% load in all of the results and get a distribution of average performance
%% on a typical run (18 trials)

datadir = fullfile(odir, 'replay', 'data', 'replay001');
files = dir(datadir);

hitRates = [];
trialsInRun = [];

for file = files'
    if (strcmp(file.name, '.') || strcmp(file.name, '..') || strendswith(file.name, '.applog'))
        fprintf('skipping %s\n', file.name);
    else
        fprintf('processing %s\n', file.name);
        [~,sta,~] = load_bcidat(fullfile(datadir, file.name));
        [starts,ends] = getEpochs(sta.TargetCode~=0, 1, false);
        hits = sum(sta.TargetCode(ends-1)==sta.ResultCode(ends-1));
        total = length(ends);
        
        hitRates = cat(1, hitRates, hits/total); 
        trialsInRun = cat(1, trialsInRun, total);
    end    
end

badTrials = trialsInRun > 20;
hitRatesFixed = hitRates(~badTrials);
trialsInRunFixed = trialsInRun(~badTrials);

% figure, hist(hitRatesFixed, 10);
% figure, plot(trialsInRunFixed);

mu = mean(hitRatesFixed);
sorted = sort(hitRatesFixed);
pctile = sorted(ceil(0.95*length(hitRatesFixed)));

% se = std(hitRatesFixed) / sqrt(length(hitRatesFixed));


fprintf(' based on %d simulated runs of %2.1f trials each, chance performance is %0.3f with a 95th percentile of %0.3f\n', ...
    length(hitRatesFixed), mean(trialsInRunFixed), mu, pctile);


%% make plots

numprops = mode(trialsInRunFixed)+1;

for c = 1:numprops
    props(c) = (c-1)/(numprops-1);
    propcts(c) = sum(hitRatesFixed==props(c));
end

propfracs = propcts / sum(propcts);

figure;
bar(props, propfracs);
hold on; 
plot((0:17)/17, binopdf(0:17, 17, .5), 'rd', 'LineWidth', 3);
xlim([0 1]);
plot([pctile pctile], ylim, 'k:', 'LineWidth', 3);
xlabel('Proportion hit');
ylabel('Fraction of observations');
title('Simulated chance performance');

legend('simulated perf', 'binomial pdf', '95th percentile');
% set(gcf, 'Position', [680   558   852   420]);

SaveFig(fullfile(odir, 'figs'), 'replay_chance_performance', 'eps');

