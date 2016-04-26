% BIOEN 599 - Biophotonics - HW3

%% a 
% Plot intermediate real/virtual image position as function of magnifying glas position 

f_lens = 100/1000;

s_o_a = [0:0.0001:1];

s_i_a = 1./(1./s_o_a - 1/f_lens);

figure
plot(s_o_a,(s_i_a + s_o_a),'linewidth',2)
xlabel('s_o_A')
ylabel('s_o_A + s_i_A')
set(gca,'fontsize',14)
title('Intermediate Image position vs. Magnifying Glass Position')
ylim([-1 1])
vline(0.1,'r:','focal length of lens')
vline(0.2,'r:')

hline(0,'g')

%% c
% plot focal length of lens in eye 


s_o_a = [0:0.0001:1];

s_i_a = 1./(1./s_o_a - 1/f_lens);

f_eye = 1./(1./(1-(s_i_a+s_o_a)) + 1/0.02);

figure
plot(s_o_a,f_eye,'linewidth',2)
xlabel('s_o_A')
ylabel('f_{eye}')
set(gca,'fontsize',14)
title('Focal Length of Eye lens to focus')
% ylim([0.0185 0.02])
% vline(0.1,'r:','focal length of lens')
% vline(0.2,'r:')

% hline(0,'g')
ylim([0.018 0.025])
hline(0.0185,'r','Physiologic limit')
hline(0.02,'r','Physiologic limit')

