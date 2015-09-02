%% Test of ecogFilter.m
%

sampRate = 1200;
dt = 1/sampRate;
t  = 0:dt:1999*dt;
t = t.';

fLineNoise = 60;
fLineNoise2 = 45;
fLowNoise = 30;
fHighNoise = 135;
fSave = 80;

f = 4*sin(2*pi*fSave*t) + 5*sin(2*pi*fLowNoise*t) + 4*sin(2*pi*fLineNoise*t) + 5*sin(2*pi*fLineNoise2*t) + 3*sin(2*pi*fHighNoise*t) + 0*randn(size(t));

subplot(7,2,1);
plot(f);
ylim([-45 45]);
subplot(7,2,2);
[F, hz] = ecogSpectra(f, sampRate);
plot(hz, F);
%ylim([0 1000]);

filt_f = ecogFilter(f, true, fLineNoise, false, 0, false, 0, sampRate);

subplot(7,2,3);
plot(filt_f);
ylim([-45 45]);
subplot(7,2,4);
[F, hz] = ecogSpectra(filt_f, sampRate);
plot(hz, F);
%ylim([0 1000]);

filt_f2 = ecogFilter(f, true, fLineNoise2, false, 0, false, 0, sampRate);

subplot(7,2,5);
plot(filt_f2);
ylim([-45 45]);
subplot(7,2,6);
[F, hz] = ecogSpectra(filt_f2, sampRate);
plot(hz, F);
%ylim([0 1000]);

filt_f3 = ecogFilter(f, true, [fLineNoise fLineNoise2], false, 0, false, 0, sampRate);

subplot(7,2,7);
plot(filt_f3);
ylim([-45 45]);
subplot(7,2,8);
[F, hz] = ecogSpectra(filt_f3, sampRate);
plot(hz, F);
%ylim([0 1000]);

filt_hp = ecogFilter(f, false, 0, true, fLowNoise+5, false, 0, sampRate);

subplot(7,2,9);
plot(filt_hp);
ylim([-45 45]);
subplot(7,2,10);
[F, hz] = ecogSpectra(filt_hp, sampRate);
plot(hz, F);
%ylim([0 1000]);

filt_lp = ecogFilter(f, false, 0, false, 0, true, fHighNoise-20, sampRate);

subplot(7,2,11);
plot(filt_lp);
ylim([-45 45]);
subplot(7,2,12);
[F, hz] = ecogSpectra(filt_lp, sampRate);
plot(hz, F);
%ylim([0 1000]);

filt_all = ecogFilter(f, true, [fLineNoise fLineNoise2], true, fLowNoise+5, true, fHighNoise-20, sampRate);

subplot(7,2,13);
plot(filt_all);
ylim([-45 45]);
subplot(7,2,14);
[F, hz] = ecogSpectra(filt_all, sampRate);
plot(hz, F);
%ylim([0 1000]);
