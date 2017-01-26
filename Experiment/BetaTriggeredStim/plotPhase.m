%% DJC plot phase script 


% need t, sid, and all the values

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% raw

figure
plot(t,fitline_pos)
hold on
plot(t,mean(fitline_pos,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('raw fitline')

fprintf('raw positive mean r_square value = %0.4f \n',mean(r_square_pos));
fprintf('raw positive mean phase at stimulus = %1.4f \n',mean(phase_at_0_pos));


figure
plot(t,fitline_neg)
hold on
plot(t,mean(fitline_neg,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('raw fitline')

fprintf('raw negative mean r_square value = %0.4f \n',mean(r_square_neg));
fprintf('raw negative mean phase at stimulus = %1.4f \n',mean(phase_at_0_neg));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% causal

figure
plot(t,fitline_pos_caus)
hold on
plot(t,mean(fitline_pos_caus,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('causal fitline')

fprintf('causal positive mean r_square value = %0.4f \n',mean(r_square_pos_caus));
fprintf('causal positive mean phase at stimulus = %1.4f \n',mean(phase_at_0_pos_caus));

figure
plot(t,fitline_neg_caus)
hold on
plot(t,mean(fitline_neg_caus,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('causal fitline')

fprintf('causal negative mean r_square value = %0.4f \n',mean(r_square_neg_caus));
fprintf('causal negative mean phase at stimulus = %1.4f \n',mean(phase_at_0_neg_caus));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% acausal 

figure
plot(t,fitline_pos_acaus)
hold on
plot(t,mean(fitline_pos_acaus,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('acausal fitline')


fprintf('acausal positive mean r_square value = %0.4f \n',mean(r_square_pos_acaus));
fprintf('acausal positive mean phase at stimulus = %1.4f \n',mean(phase_at_0_pos_acaus));

figure
plot(t,fitline_neg_acaus)
hold on
plot(t,mean(fitline_neg_acaus,2),'k','linewidth',4)
xlabel('time (s)')
ylabel('\mu V')
title('acausal fitline')


fprintf('acausal negative mean r_square value = %0.4f \n',mean(r_square_neg_acaus));
fprintf('acausal negative mean phase at stimulus = %1.4f \n',mean(phase_at_0_neg_acaus));
