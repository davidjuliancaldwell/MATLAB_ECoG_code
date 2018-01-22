% % path=fullfile('PAC ECoG','S1');
% % % [signal,states,par]=load_bcidat(fullfile(path,'a9952e_baseline8S001R01.dat'));
% % % fs=par.SamplingRate.NumericValue;
% % load(fullfile(path,'data.mat'));
% % f1=.5;f2=300;
% % data=butter_filter(data,f1,f2,fs,4);
% % x1=data(:,33);
% % x2=data(:,42);


%%% REQUIRES THE WAVELET TOOLBOX. WILL NOT RUN ON A COMPUTER WITHOUT THE
%%% WAVELET TOOLBOX. YOUR COMPUTER DOES NOT HAVE THE WAVELET TOOLBOX AS OF
%%% JULY 2015.


function pac=compute_pac_amp(x,y,fwx,fwy,fs)
% function compute_pac_amp(x,y,fwx,fwy,fs)
% amplitude phase locking
 
% x and y are signals
% fwx is frequencies to test x at
% fwy is frequencies to test y at
% fs is sampling rate

[~,~,Callx,~]=time_frequency_wavelet(x,fwx,fs,1,1,'CPUtest');
[~,~,Cally,~]=time_frequency_wavelet(y,fwy,fs,1,1,'CPUtest');
px=Callx./abs(Callx);
ay=abs(Cally);
pac=abs(ay'*px)/size(px,1);



% figure
% for i=1:16
%     subplot(2,8,i);
%     pac=compute_pac_plv(datax(:,i),datax(:,i),fwx,fwy,fs);
%     contourf(fwx,fwy,pac',30,'LineColor','none');
%     %caxis([0 1e-3]);
%     drawnow;
% end


end