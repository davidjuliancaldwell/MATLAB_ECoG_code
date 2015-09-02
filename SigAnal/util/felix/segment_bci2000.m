function [epoch_data,t,fs,epoch_finger,rt,channel, offsets]=segment_bci2000(mysignals, mystates, myparams,segment_size,mode,code, tbase_finger,tr,refmode,bad_channels,filt)
%function [epoch_data,t,fs,epoch_finger,rt,channel]=segment_bci2000(fname,segment_size,mode,code, tbase_finger,tr,refmode,bad_channels,filt)

% reads in BCI2000 data and converts to epochs, based on the data glove
% input
% fname = absolute path to BCI2000 file (as .mat) expects 3 variables:
% that must have 'signal', 'state' and 'param' as part of their name
% [WRONG]
% segment_size = [-samples before smaples after] specifies interval around stimulus onset in samples
% mode = how to segment the data 'cue' or 'finger'(default)
% code = which finger code 2= thumb, 3=index 4= middle 5=ring 6=pinky 7=
% pinch
% tbase_finger = baseline (in s) the mean over this period is subtracted
% from the data glove output
% tr = threshold for movement onset...~80 seems to work
% refmode = rerefence mode 'car' or 'svd';
% bad_channels = list of channels to exclude for rereferencing
% filt = [f1 f2] if the raw data should be filtered.empty if not
% output
% epoch_data : the data segmented based on the stim code/cue/finger
% t : time vector
% fs: sampling rate
% epoch_finger : corresponding data glove output
% rt: reaction time for each trial
% channel: the channel used to make the trial selection

% load(fname);
% if(~exist('myparams','var'))
%  a=whos('-regexp','param');
%  eval(sprintf('myparams=%s',a.name));
%  eval(sprintf('clear %s',a.name));
% end
% if(~exist('mystates','var'))
%  a=whos('-regexp','state');
%  eval(sprintf('mystates=%s',a.name));
%  eval(sprintf('clear %s',a.name));
% end
% if(~exist('mysignals','var'))
%  a=whos('-regexp','signal');
%  eval(sprintf('mysignals=%s',a.name));
%  eval(sprintf('clear %s',a.name));
% end

fs= double( myparams.SamplingRate.NumericValue);
gc=1:size(mysignals,2);gc(bad_channels)=[];
% mysignals=rereference(double(mysignals),refmode,gc);
if(~isempty(filt))
    mysignals=butter_filter(mysignals,filt(1),filt(2),fs,4);
end
nsamples=size(mysignals,1);
fingers=zeros(nsamples,22);
for i=1:size(fingers,2)
eval(sprintf('fingers(:,%i)=double(mystates.Cyber%i);',i,i));
end
%fingers=butter_filter(fingers,.1,10,fs,3);
f1 = [];
for i=code
    temp = getEpochs(mystates.StimulusCode, i);
    f1 = [f1; temp'];
end

% f1=find(diff(mystates.StimulusCode==code)>0); % 1st step: segment for stimulus cue
ixs=segment_size(1):segment_size(2);
t=ixs'/fs;
% segment data_glove output
epoch_finger=zeros(length(ixs),22,length(f1));
for i=1:length(f1)
    epoch_finger(:,:,i)=fingers(ixs+f1(i),:);
end

for i=1:length(f1)
    a=epoch_finger(:,:,i);
    a=a-repmat(mean(a(t>tbase_finger(1) & t<tbase_finger(2),:),1),size(a,1),1);
    epoch_finger(:,:,i)=a;
end
shft=f1;rt=f1;channel=f1;
for i=1:length(f1)
    a=epoch_finger(:,:,i);
    [U,S,V]=svd(cov(a)); % get the principal components of the 22 finger channels
    a0=a(t>0,:);
    [ax,ixx]=max(a0(:));% or just pick the strongest component... 
    [ti,ch]=ind2sub(size(a0),ixx);
    x=(a*U(:,1)).^2;
    x=a(:,ch).^2;
    gx=[0;diff(x)]; %and compute its gradient
    ix=find(diff(x>tr)>0); % select onset
    ix=min(ix(t(ix)>0));
    if(strcmp(mode, 'cue') == 1)
        channel(i) = 0;
    elseif (isempty(ix))
        channel(i)=-1;
    else
    shft(i)=segment_size(1)+ix;
    rt(i)=t(ix);
    channel(i)=ch;
    end
%     figure
%    
%     plot(t,a.^2,'k');
%     hold on
%     plot(t,x);    
%     plot(t,a(:,1:3).^2,'r');
%     plot(t(ix),x(ix),'or');
end
f1(channel<0)=[];
rt(channel<0)=[];
shft(channel<0)=[];

epoch_data=zeros(length(t),size(mysignals,2),length(f1));
switch(mode)
    case 'cue'
        offsets = f1;
        for i=1:length(f1)
            epoch_data(:,:,i)=double(mysignals(f1(i)+ixs,:));
        end
    case 'finger'
        offsets = f1 + shft;
        for i=1:length(f1)
         epoch_data(:,:,i)=double(mysignals(f1(i)+shft(i)+ixs,:));
         epoch_finger(:,:,i)=fingers(ixs+f1(i)+shft(i),:);
        end
    otherwise
       for i=1:length(f1)
         epoch_data(:,:,i)=double(mysignals(f1(i)+shft(i)+ixs,:));
         epoch_finger(:,:,i)=fingers(ixs+f1(i)+shft(i),:);
        end
        
end
        
for i=1:length(f1)
    a=epoch_finger(:,:,i);
    a=a-repmat(mean(a(t>tbase_finger(1) & t<tbase_finger(2),:),1),size(a,1),1);
    epoch_finger(:,:,i)=a;
end



