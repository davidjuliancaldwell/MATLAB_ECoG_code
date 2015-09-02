%% 6/30/2014 Proprioception work 
% load in data, plot it 
% Subjects 828260, 4087bd 
[sig, sta, par] = load_bcidatUI(pwd);
PlotStates(sta,par);

par.SamplingRate;
freq = 1200;

%%
