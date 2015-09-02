%% error checking

if (isempty(which('bci2000path')))
    error('Please add the bci2000 matlab tools directory to your matlab path.');
end

if (isempty(which('load_bcidat')))
    error('Please add the bci2000 matlab mex directory to your matlab path.');
end

%% get the paths to the files of interest

[recFilename, recFilepath] = uigetfile('*.dat', 'Select a BCI2000 Recording file', bci2000path);
recFile = fullfile(recFilepath, recFilename);

[logFilename, logFilepath] = uigetfile('', 'Select a BCI2000 console output log file', pwd);
logFile = fullfile(logFilepath, logFilename);

%% load in the parameters used in the recording
[~,~,par] = load_bcidat(recFile);
parstr = make_bciprm(par);

% and write them out to a file
handle = fopen('replay.prm', 'w');
fwrite(handle, parstr);
fclose(handle);

%% run the bci2000chain, note the omission of the ExpressionFilter, should
% be ok because it is setup as a passthrough by default.
output = bci2000chain(recFile, 'TransmissionFilter|SpatialFilter|ARFilter|LinearClassifier|LPFilter|Normalizer', '-2', 'replay.prm');

synthesized = output.Signal;

%% now parse the log file you just created

handle = fopen(logFile,'r');
line = fgetl(handle);
realtime = [];

while line > 0
    temp = regexp(line, '.*?ess: ([0-9\. ]+).', 'tokens');
    if (~isempty(temp))
        realtime(end+1,:) = sscanf(temp{1}{1}, '%f %f %f %f');
    end
    line = fgetl(handle);
end

fclose(handle);

%% force the same length, for easy comparison
len = min(size(realtime, 1), size(synthesized, 1));

synthesized = synthesized(1:len,:);
realtime    = realtime(1:len,:);

%% visual comparison
figure
for c = 1:2
    subplot(2,1,c);
    plot(realtime(:,c));
    hold on;
    plot(synthesized(:,c), 'g:');
    
    legend('realtime', 'synthesized');
    title(sprintf('channel %d', c));
end

%% numeric comparison
mse = mean((realtime-synthesized).^2,1);
fprintf('Mean Squared Error by channel: %s\n', num2str(mse));
fprintf('As a percent of dynamic range: %s\n', num2str(mse ./ range(realtime,1) * 100));
