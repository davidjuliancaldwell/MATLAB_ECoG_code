%% - 3-30-2016 - DJC - response timing file generator
% this script will generate two text files. One of these has the sample
% number at which each stimulus train will be delivered. the second has the
% condition which should be read in 

sid = input('what is the subject id?\n','s');

ITI = input('What is the range of ITI to use? (in seconds, input as [1.5,2.5]) ?\n');

fs = input('What is the sample rate/clock rate of the TDT system in Hz?');

% fs = 24414.06 


%% make the timing file 
ITIlo = ITI(1)+0.8;
ITIhi = ITI(2)+0.8;

randTimes = unifrnd(ITIlo,ITIhi,120,1);


% here the vector is converted to the sample number where the stimulus
% train should start to be delivered 
sample = 1; % start with sample 1 
pts = [];
for i = 1:length(randTimes)
    sample = floor(sample + randTimes(i)*fs);
    pts = [pts; sample];
end



%% make the conditions file

a = repmat(0,100,1);
b = repmat(1,20,1);
c = repmat(2,20,1);

vectorCond = [a;b;c];

vectorCondRand = vectorCond(randperm(length(vectorCond)));



%% write these times to file for stim train delivery

filename = sprintf('%s_stimTrainDelivery.txt',sid);
fileID = fopen(filename,'w');
fprintf(fileID,'%d\r\n',pts);
fclose(fileID);

%% write these times to file for condition 

filename = sprintf('%s_condition.txt',sid);
fileID = fopen(filename,'w');
fprintf(fileID,'%d\r\n',vectorCondRand);
fclose(fileID);