ddc={'outbound','inbound'};
nperm=100;
s=3;
dc=1;

subj=sprintf('S%i',s+1);
direction=ddc{dc};

[data,clist,control,fs,tr]=get_subject_data(subj,5,.5,300,4);
data=cheby_filter_notch(data,58,62,fs,4);
data=cheby_filter_notch(data,118,122,fs,4);
data=cheby_filter_notch(data,178,182,fs,4);


inbound=load(fullfile(subj,'results_max_inbound.mat'));

outbound=load(fullfile(subj,'results_max_outbound.mat'));
figure
for i=1: length(outbound.clist)
    subplot(8,4,i);
    imagesc(outbound.fwa,outbound.fwb,inbound.map_all{inbound.clist(i)});
    caxis([0 0.04]);
    axis xy;
end
fwa=inbound.fwa;
fwb=inbound.fwb;
x=data(:,control);
y=data(:,inbound.clist(8));
[map,maxd,fwc]=compute_bplv_cont(y,y,x,fwa,fwb,fs,0,-1);
figure
imagesc(fwa,fwb,map')
axis xy;

f1=12;
f2=90;
f3=f1+f2;
[~,~,p1,~]=time_frequency_wavelet(y,[f1 f2],fs,0,1,'CPUtest');
[~,~,p2,~]=time_frequency_wavelet(x,f3,fs,0,1,'CPUtest');
p1=p1./abs(p1);

p1s=p1(:,1).*p1(:,2);
p2=p2./abs(p2);

    pacn=compute_pac_amp(x,y,fwa,fwb,fs,'norm');

    pac0=compute_pac_amp(x,y,fwa,fwb,fs);

