%% DJC plot phase script 


% need t, sid, and all the values

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%positive

figure

subplot(2,3,1)
plot(t,fitline_pos)
hold on
plot(t,mean(fitline_pos,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('raw positive fitline')

fprintf('raw positive mean r_square value = %0.4f \n',mean(r_square_pos));
fprintf('raw positive mean phase at stimulus = %1.4f \n',mean(phase_at_0_pos));
fprintf('raw positive mean frequency of fit curve = %2.1f \n',mean(f_pos));

subplot(2,3,4)
plotBTLError(t,fitline_pos,'CI');
xlabel('time (s)')
ylabel('\mu V')
title('raw positive fitline')

subplot(2,3,2)
plot(t,fitline_pos_caus)
hold on
plot(t,mean(fitline_pos_caus,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('causal positive fitline')

fprintf('causal positive mean r_square value = %0.4f \n',mean(r_square_pos_caus));
fprintf('causal positive mean phase at stimulus = %1.4f \n',mean(phase_at_0_pos_caus));
fprintf('causal positive mean frequency of fit curve = %2.1f \n',mean(f_pos_caus));

subplot(2,3,5)
plotBTLError(t,fitline_pos_caus,'CI');
xlabel('time (s)')
ylabel('\mu V')
title('causal positive fitline')

subplot(2,3,3)
plot(t,fitline_pos_acaus)
hold on
plot(t,mean(fitline_pos_acaus,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('acausal positive fitline')


fprintf('acausal positive mean r_square value = %0.4f \n',mean(r_square_pos_acaus));
fprintf('acausal positive mean phase at stimulus = %1.4f \n',mean(phase_at_0_pos_acaus));
fprintf('acausal positive mean frequency of fit curve = %2.1f \n',mean(f_pos_acaus));

subplot(2,3,6)
plotBTLError(t,fitline_pos_acaus,'CI');
xlabel('time (s)')
ylabel('\mu V')
title('acausal positive fitline')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% negative


figure

subplot(2,3,1)

plot(t,fitline_neg)
hold on
plot(t,mean(fitline_neg,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('raw negative fitline')

fprintf('raw negative mean r_square value = %0.4f \n',mean(r_square_neg));
fprintf('raw negative mean phase at stimulus = %1.4f \n',mean(phase_at_0_neg));
fprintf('raw negative mean frequency of fit curve = %2.1f \n',mean(f_neg));


subplot(2,3,4)
plotBTLError(t,fitline_neg,'CI');
xlabel('time (s)')
ylabel('\mu V')
title('raw negative fitline')


subplot(2,3,2)
plot(t,fitline_neg_caus)
hold on
plot(t,mean(fitline_neg_caus,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('causal negative fitline')

fprintf('causal negative mean r_square value = %0.4f \n',mean(r_square_neg_caus));
fprintf('causal negative mean phase at stimulus = %1.4f \n',mean(phase_at_0_neg_caus));
fprintf('causal negative mean positive frequency of fit curve = %2.1f \n',mean(f_neg_caus));

subplot(2,3,5)
plotBTLError(t,fitline_neg_caus,'CI');
xlabel('time (s)')
ylabel('\mu V')
title('causal negative fitline')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% acausal 

subplot(2,3,3)
plot(t,fitline_neg_acaus)
hold on
plot(t,mean(fitline_neg_acaus,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('acausal negative fitline')


fprintf('acausal negative mean r_square value = %0.4f \n',mean(r_square_neg_acaus));
fprintf('acausal negative mean phase at stimulus = %1.4f \n',mean(phase_at_0_neg_acaus));
fprintf('acausal negative mean frequency of fit curve = %2.1f \n',mean(f_neg_acaus));

subplot(2,3,6)
plotBTLError(t,fitline_neg_acaus,'CI');
xlabel('time (s)')
ylabel('\mu V')
title('acausal negative fitline')




%%
% do the part for single pts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% raw

figure

subplot(2,3,1)
plot(t,fitline)
hold on
plot(t,mean(fitline,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('raw fitline')

fprintf('raw mean r_square value = %0.4f \n',mean(r_square));
fprintf('raw mean phase at stimulus = %1.4f \n',mean(phase_at_0));
fprintf('raw mean frequency of fit curve = %2.1f \n',mean(f));

subplot(2,3,4)
plotBTLError(t,fitline,'CI');
xlabel('time (s)')
ylabel('\mu V')
title('raw fitline')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% causal

subplot(2,3,2)
plot(t,fitline_caus)
hold on
plot(t,mean(fitline_caus,2),'k','LineWidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('causal fitline')

fprintf('causal mean r_square value = %0.4f \n',mean(r_square_caus));
fprintf('causal mean phase at stimulus = %1.4f \n',mean(phase_at_0_caus));
fprintf('causal mean frequency of fit curve = %2.1f \n',mean(f_caus));

subplot(2,3,5)
plotBTLError(t,fitline_caus,'CI');
xlabel('time (s)')
ylabel('\mu V')
title('causal fitline')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% acausal 

subplot(2,3,3)
plot(t,fitline_acaus)
hold on
plot(t,mean(fitline_acaus,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('acausal fitline')


fprintf('acausal positive mean r_square value = %0.4f \n',mean(r_square_acaus));
fprintf('acausal positive mean phase at stimulus = %1.4f \n',mean(phase_at_0_acaus));
fprintf('acausal mean frequency of fit curve = %2.1f \n',mean(f_acaus));

subplot(2,3,6)
plotBTLError(t,fitline_acaus,'CI');
xlabel('time (s)')
ylabel('\mu V')
title('acausal fitline')


