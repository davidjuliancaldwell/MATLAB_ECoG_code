path=fullfile('S1');
%
[signal,states,par]=load_bcidat(fullfile(path,'a9952e_baseline8S001R01.dat')
);
% fs=par.SamplingRate.NumericValue;
load(fullfile(path,'data.mat'));
f1=.5;f2=300;
data=butter_filter(data,f1,f2,fs,4);
x1=data(:,33);
x2=data(:,42);

datax=data(:,33:48);
datax=datax-repmat(mean(datax,2),1,size(datax,2));
fwx=2:20;fwy=40:5:200;
fwa=3:30;fwb=40:170;
figure
for i=1:16
    subplot(2,8,i);
    %pac=compute_pac_plv(,fwx,fwy,fs);
    pac=compute_pac_amp(datax(:,i),datax(:,i),fwx,fwy,fs);
    %[map,~]=compute_bplv_cont(datax(:,i),datax(:,i),datax(:,i),fwb,fwa,fs,1
);
    %contourf(fwa,fwb,map,30,'LineColor','none');
    contourf(fwx,fwy,pac',30,'LineColor','none');
    %caxis([0 1e-3]);
    drawnow;
end




