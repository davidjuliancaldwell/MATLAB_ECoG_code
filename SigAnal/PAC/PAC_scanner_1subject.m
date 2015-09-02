%ddc={'outbound','inbound'};
sc=1;
n=40;

subj = 'fca96e';

% for s=1:4
%         subj=sprintf('S%i',s+1);
%direction=ddc{dc};

%[data,clist,control,fs,tr]=get_subject_data(subj,5,.5,300,4);

load(strcat(subj, '_basicanalysis.mat'), 'trimmed_sig');
data = trimmed_sig; clear trimmed_sig;
load(strcat(subj, '_basicanalysis.mat'), 'fs');

% data=notch(data,[58 62],fs,4);
% data=notch(data,[118 122],fs,4);
% data=notch(data,[178 182],fs,4);

% data=data-repmat(mean(data,2),1,size(data,2));

% elsewhere=1:size(data,2);
% elsewhere(clist)=[];

fwa=3:30;
fwb=40:170;


[p,q] = rat(600/fs); %to set the new fs to 600, about half of old
data = resample(data, p, q);
% data=resample(data,1,2); %we have to do all this bullshit because the
% sampling rate is not necessarily an integer
fs = 600;

%% YOU MUST DO THIS PART ON A COMPUTER THAT HAS THE WAVELET TOOLBOX.

tic
map=compute_pac_amp_allchannels(data(:,:),fwa,fwb,fs,1,'norm');
save(fullfile(subj,sprintf('results_pac_norm_all.mat')),'fs','map','fwa','fwb','-v7.3');
t2=toc;
fprintf('took %4.0f seconds\n',t2);

% end
