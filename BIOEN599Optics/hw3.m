% BIOEN 599 - Biophotonics - HW3

%% a 
% Plot intermediate real/virtual image position as function of magnifying glas position 
close all;clearvars;clc
f_lens = 100/1000;

s_o_a = [0:0.0001:1];

% s_i_a = 1./(1./s_o_a - 1/f_lens);

s_i_a = (s_o_a.*f_lens)./(s_o_a-f_lens);

s_comb = s_i_a + s_o_a; 
figure
subplot(2,1,1)
plot(s_o_a,(s_comb),'linewidth',2)
ylim([-1 1])
xlim([0 1])
xlabel('s_o_A (m)')
ylabel('s_o_A + s_i_A (m)')
set(gca,'fontsize',14)
title({'Intermediate Image position','Taking Into Account Lens Position' 'vs. Magnifying Glass Position'})
vline(0.1,'r:','object at focal length of lens')
hline(0,'g')


subplot(2,1,2)
plot(s_o_a,(s_i_a),'linewidth',2)
ylim([-1 1])
xlim([0 1])
xlabel('s_o_A (m)')
ylabel('s_i_A (m)')
set(gca,'fontsize',14)
title({'Intermediate Image position','Disregarding lens position' 'vs. Magnifying Glass Position'})
vline(0.1,'r:','object at focal length of lens')

hline(0,'g')

%% c
% plot focal length of lens in eye 
s_o_a = [0:0.0001:1];
s_i_a = (s_o_a.*f_lens)./(s_o_a-f_lens);
s_comb = s_i_a + s_o_a; 

s_o_new = 1-s_comb;
s_i_b = 0.02;
f_eye = (s_o_new.*s_i_b)./(s_o_new + s_i_b);

figure
plot(s_o_a,f_eye,'linewidth',2)
xlabel('s_o_A (m)')
ylabel('f_{eye}')
set(gca,'fontsize',14)
title('Focal Length of Eye lens to focus')
% ylim([0.0185 0.02])
% vline(0.1,'r:','focal length of lens')
% vline(0.2,'r:')

% hline(0,'g')
ylim([0.01 0.04])
hline(0.0185,'r','Physiologic limit')
hline(0.02,'r')

vline(0.1,'g','object at focal length of lens')
vline(0.75,'b','near point of eye')

%% 
figure
plot(s_o_a,(s_comb),'linewidth',2)
ylim([-1 1])
xlim([0 1])
xlabel('s_o_A (m)')
ylabel('s_o_A + s_i_A (m)')
set(gca,'fontsize',14)
title({'Intermediate Image position'})
vline(0.1,'r:','object at focal length of lens')
hline(0.75,'g', 'this is the near point of the eye')

%% magnification

% unaided = -0.25;

% aided =  -0.02./s_o_new;

magnif = (s_o_new);

figure
subplot(2,1,1)
plot(s_o_a, magnif,'linewidth',2);
% vline(0.1)
xlabel('s_o_A (m)')
ylabel('Magnification')
title ({'Magnification vs. magnifying glass position','before divergence'})
set(gca,'fontsize',14)
% ylim([-3 3])
ylim([0 6])
xlim([0 0.1])

subplot(2,1,2)
magnif = -(s_o_new);
plot(s_o_a, magnif,'linewidth',2);
% vline(0.1)
xlabel('s_o_A (m)')
ylabel('Magnification')
title ({'Magnification vs. magnifying glass position','after divergence'})
set(gca,'fontsize',14)
% ylim([-3 3])
ylim([-1 0])
xlim([0.1 1])




