%% DJC 4-30-2018 - DJC test front panel latency 

DATA_DIR = 'G:\My Drive\betaStim_oScope_test\betaStim_oScope_converted';

fileNum = 1;
load(fullfile(DATA_DIR,['frontPanel_latecy-',num2str(fileNum),'.mat']));

%%

tact1 = Tact.data(:,1);
tact2 = Tact.data(:,2);
fsTact = Tact.info.SamplingRateHz;
t = [0:length(tact1)-1]*1e3/fsTact;

eco1 = interp(ECO1.data(:,1),2)';
eco1 = eco1(1:length(tact1));

figure
plot(t,eco1)
hold on
plot(t,tact1)
plot(t,tact2)
legend('raw signal','front panel channel 1','front panel channel 2')