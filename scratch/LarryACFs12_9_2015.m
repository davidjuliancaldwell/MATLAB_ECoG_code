%% 12-9-2015 - File from Larry looking at acfs of ecb43e - electrode 63 mostly 

mmm=mean(S(:,63));

figure;a2=xcorr(S(:,63)-mmm,S(:,63)-mmm,'coeff');plot(a2);
figure;a2=xcorr(S(1:100000,63)-mmm,S(1:100000,63)-mmm,'coeff');plot(a2);
figure;a2=xcorr(S(100001:200000,63)-mmm,S(100001:200000,63)-mmm,'coeff');plot(a2);
figure;a2=xcorr(S(200001:300000,63)-mmm,S(200001:300000,63)-mmm,'coeff');plot(a2);
figure;a2=xcorr(S(300001:400000,63)-mmm,S(300001:400000,63)-mmm,'coeff');plot(a2);
figure;a2=xcorr(S(400001:500000,63)-mmm,S(400001:500000,63)-mmm,'coeff');plot(a2);
figure;a2=xcorr(S(500001:600000,63)-mmm,S(500001:600000,63)-mmm,'coeff');plot(a2);
figure;a2=xcorr(S(600001:700000,63)-mmm,S(600001:700000,63)-mmm,'coeff');plot(a2);
figure;a2=xcorr(S(700001:800000,63)-mmm,S(700001:800000,63)-mmm,'coeff');plot(a2);
figure;start=1;stop=10000;for j=1:8;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,8,j);plot(a2);axis([0, 20000, -0.2, 1.05])hold on;start=start+10000;stop=stop+10000;end;


figure;start=1;stop=1000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=100001;stop=101000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=200001;stop=201000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=300001;stop=301000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=400001;stop=401000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=500001;stop=501000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=600001;stop=601000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=700001;stop=701000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+1000;stop=stop+1000;end;

 
figure;start=1;stop=1000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+100;stop=stop+100;end;
figure;start=1;stop=1000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+10;stop=stop+10;end;
figure;start=1;stop=1000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+50;stop=stop+50;end;
figure;start=1;stop=1000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+200;stop=stop+200;end;
figure;start=1;stop=1000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+500;stop=stop+500;end;
figure;start=1;stop=1000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+400;stop=stop+400;end;
figure;start=1;stop=1000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+300;stop=stop+300;end;


mm=mean(S(:,64));

figure;start=1;stop=1000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,64)-mm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=1;stop=1000;for j=1:100;a2=xcorr(S(start:stop,64)-mm,S(start:stop,64)-mm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=1;stop=1000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,63)-mmm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=100001;stop=101000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,64)-mm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -0.2, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=100001;stop=101000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,64)-mm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -1.05, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=200001;stop=201000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,64)-mm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -1.05, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=300001;stop=301000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,64)-mm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -1.05, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=400001;stop=401000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,64)-mm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -1.05, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=500001;stop=501000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,64)-mm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -1.05, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=600001;stop=601000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,64)-mm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -1.05, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=700001;stop=701000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,64)-mm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -1.05, 1.05]);hold on;start=start+1000;stop=stop+1000;end;
figure;start=1;stop=1000;for j=1:100;a2=xcorr(S(start:stop,63)-mmm,S(start:stop,64)-mm,'coeff');subplot(10,10,j);plot(a2);axis([1, 2000, -1.05, 1.05]);hold on;start=start+1000;stop=stop+1000;end;