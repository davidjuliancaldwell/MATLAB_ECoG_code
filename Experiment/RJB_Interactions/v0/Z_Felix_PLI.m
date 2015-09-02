tic

% load 30052b-data
load d:\research\code\output\1DBCI_Interaction\meta\30052b-data.mat

fw=1:1:103;
ix=find(abs(targets-results)<eps);


x=squeeze(data(:,1,ix));
y=squeeze(data(:,4,ix));

[C2,CS,Callx,C0]=time_frequency_wavelet(x,fw,fs,1,1,'CPUtest');
[C2,CS,Cally,C0]=time_frequency_wavelet(y,fw,fs,1,1,'CPUtest');


Callx=Callx./abs(Callx);
Cally=Cally./abs(Cally);
%%
t1=3;t2=6;
uCallx=Callx(:,:,(end-29):end);
uCally=Cally(:,:,(end-29):end);

dp=uCallx.*conj(uCally);



si=sign(imag(dp));
n=1000;

spc=squeeze(mean(mean(si(t>t1 & t<t2,:,:),3),1))';
spc_perm=zeros(length(fw),n);
tic
for i=1:n
    dpp=uCallx.*conj(uCally(:,:,randperm(size(uCally,3))));
    si=sign(imag(dpp));
    spcr=squeeze(mean(mean(si(t>t1 & t<t2,:,:),3),1));
    spc_perm(:,i)=spcr';
end
toc

f1=figure;
plot(fw,spc);
hold on
f2=figure;
plot(log10(1-mean(repmat(spc,1,n)<spc_perm,2)),'b')
hold on

uCallx=Callx(:,:,1:30);
uCally=Cally(:,:,1:30);

dp=uCallx.*conj(uCally);



si=sign(imag(dp));

spc=squeeze(mean(mean(si(t>t1 & t<t2,:,:),3),1))';
spc_perm=zeros(length(fw),n);
tic
for i=1:n
    dpp=uCallx.*conj(uCally(:,:,randperm(size(uCally,3))));
    si=sign(imag(dpp));
    spcr=squeeze(mean(mean(si(t>t1 & t<t2,:,:),3),1));
    spc_perm(:,i)=spcr';
end
toc
figure(f1);plot(fw,spc,'r');
figure(f2);plot(log10(1-mean(repmat(spc,1,n)<spc_perm,2)),'r')

toc