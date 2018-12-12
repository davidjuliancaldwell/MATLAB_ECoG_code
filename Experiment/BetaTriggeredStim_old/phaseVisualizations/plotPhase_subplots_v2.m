%% DJC plot phase script


% need t, sid, and all the values

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%positive
%%
close all;clear all;clc
baseDir = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\PhaseOfDelivery';
filePath = promptForBCI2000Recording(baseDir);
load(filePath)

type = input('single or multiple phase of delivery? input "s" or "m"\n','s');

%%

if strcmp(type,'m')
    figure
    
    subplot(2,1,1)
    plot(1e3*t,fitline_pos)
    hold on
    plot(1e3*t,mean(fitline_pos,2),'k','linewidth',4)
    %xlabel('time before stimulation (ms)')
    %ylabel('\mu V')
    title('raw positive fitline')
    set(gca,'fontsize',14)
    xlim([-50 0])
    
    fprintf('raw positive mean r_square value = %0.4f \n',mean(r_square_pos));
    fprintf('raw positive mean phase at stimulus = %1.4f \n',mean(phase_at_0_pos));
    fprintf('raw positive mean frequency of fit curve = %2.1f \n',mean(f_pos));
    set(gca,'fontsize',14)
    xlim([-50 0])
    
    subplot(2,1,2)
    plotBTLError(1e3*t,fitline_pos,'CI');
    %xlabel('time before stimulation (ms)')
    %ylabel('\mu V')
    title({'raw positive fitline',' 95% confidence interval'})
    set(gca,'fontsize',14)
    xlim([-50 0])
    
%     subplot(2,2,2)
%     plot(1e3*t,fitline_pos_caus)
%     hold on
%     plot(1e3*t,mean(fitline_pos_caus,2),'k','linewidth',4)
%     %xlabel('time before stimulation (ms)')
%     %ylabel('\mu V')
%     title('causal positive fitline')
%     set(gca,'fontsize',14)
%     xlim([-50 0])
%     
%     fprintf('causal positive mean r_square value = %0.4f \n',mean(r_square_pos_caus));
%     fprintf('causal positive mean phase at stimulus = %1.4f \n',mean(phase_at_0_pos_caus));
%     fprintf('causal positive mean frequency of fit curve = %2.1f \n',mean(f_pos_caus));
%     
%     subplot(2,2,4)
%     plotBTLError(1e3*t,fitline_pos_caus,'CI');
%     xlabel('time before stimulation (ms)')
%     ylabel('\mu V')
%     title({'causal positive fitline',' 95% confidence interval'})
%     xlim([-50 0])
    
    set(gca,'fontsize',14)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % negative
    %%
    
    figure
    
    subplot(2,1,1)
    
    plot(1e3*t,fitline_neg)
    hold on
    plot(1e3*t,mean(fitline_neg,2),'k','linewidth',4)
    %xlabel('time before stimulation (ms)')
    %ylabel('\mu V')
    title('raw negative fitline')
    set(gca,'fontsize',14)
    xlim([-50 0])
    
    fprintf('raw negative mean r_square value = %0.4f \n',mean(r_square_neg));
    fprintf('raw negative mean phase at stimulus = %1.4f \n',mean(phase_at_0_neg));
    fprintf('raw negative mean frequency of fit curve = %2.1f \n',mean(f_neg));
    
    
    subplot(2,1,2)
    plotBTLError(1e3*t,fitline_neg,'CI');
    %xlabel('time before stimulation (ms)')
    %ylabel('\mu V')
    title({'raw negative fitline',' 95% confidence interval'})
    set(gca,'fontsize',14)
    xlim([-50 0])
    
    
%     subplot(2,2,2)
%     plot(1e3*t,fitline_neg_caus)
%     hold on
%     plot(1e3*t,mean(fitline_neg_caus,2),'k','linewidth',4)
%     %xlabel('time before stimulation (ms)')
%     %ylabel('\mu V')
%     title('causal negative fitline')
%     set(gca,'fontsize',14)
%     xlim([-50 0])
    
%     fprintf('causal negative mean r_square value = %0.4f \n',mean(r_square_neg_caus));
%     fprintf('causal negative mean phase at stimulus = %1.4f \n',mean(phase_at_0_neg_caus));
%     fprintf('causal negative mean positive frequency of fit curve = %2.1f \n',mean(f_neg_caus));
%     
%     subplot(2,2,4)
%     plotBTLError(1e3*t,fitline_neg_caus,'CI');
%     xlabel('time before stimulation (ms)')
%     ylabel('\mu V')
%     title({'causal negative fitline',' 95% confidence interval'})
%     set(gca,'fontsize',14)
%     xlim([-50 0])
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % acausal
    
end

%%
% do the part for single pts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% raw
if strcmp(type,'s')
    figure
    
    subplot(2,2,1)
    plot(t,fitline)
    hold on
    plot(t,mean(fitline,2),'k','linewidth',4)
    xlabel('time (s)')
    ylabel('\mu V')
    title('raw fitline')
    set(gca,'fontsize',14)
    xlim([-50 0])
    fprintf('raw mean r_square value = %0.4f \n',mean(r_square));
    fprintf('raw mean phase at stimulus = %1.4f \n',mean(phase_at_0));
    fprintf('raw mean frequency of fit curve = %2.1f \n',mean(f));
    
    subplot(2,2,3)
    plotBTLError(t,fitline,'CI');
    xlabel('time (s)')
    ylabel('\mu V')
    title('raw fitline')
    set(gca,'fontsize',14)
    xlim([-50 0])
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % causal
    
    subplot(2,2,2)
    plot(t,fitline_caus)
    hold on
    plot(t,mean(fitline_caus,2),'k','LineWidth',4)
    xlabel('time (s)')
    ylabel('\mu V')
    title('causal fitline')
    set(gca,'fontsize',14)
    xlim([-50 0])
    
    fprintf('causal mean r_square value = %0.4f \n',mean(r_square_caus));
    fprintf('causal mean phase at stimulus = %1.4f \n',mean(phase_at_0_caus));
    fprintf('causal mean frequency of fit curve = %2.1f \n',mean(f_caus));
    
    subplot(2,2,4)
    plotBTLError(t,fitline_caus,'CI');
    xlabel('time (s)')
    ylabel('\mu V')
    title('causal fitline')
    set(gca,'fontsize',14)
    xlim([-50 0])
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % acausal
    %
    % subplot(2,3,3)
    % plot(t,fitline_acaus)
    % hold on
    % plot(t,mean(fitline_acaus,2),'k','linewidth',4)
    % xlabel('time (s)')
    % ylabel('\mu V')
    % title('acausal fitline')
    %
    %
    % fprintf('acausal positive mean r_square value = %0.4f \n',mean(r_square_acaus));
    % fprintf('acausal positive mean phase at stimulus = %1.4f \n',mean(phase_at_0_acaus));
    % fprintf('acausal mean frequency of fit curve = %2.1f \n',mean(f_acaus));
    %
    % subplot(2,3,6)
    % plotBTLError(t,fitline_acaus,'CI');
    % xlabel('time (s)')
    % ylabel('\mu V')
    % title('acausal fitline')
    %
    %
end