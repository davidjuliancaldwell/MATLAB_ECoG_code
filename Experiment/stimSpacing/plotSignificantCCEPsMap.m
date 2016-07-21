%% 7-19-2016 - Function to plot significant CCEP map

function [] = plotSignificantCCEPsMap(sig,t,stims,chansCCEPs,cceps)
% JC: sig must be 3D: time*channels*epochs
% or, 2D: time*channels

figure
%cceps = 'yes';


CT = cbrewer('qual','Set1',3);


for idx = 1:64
    smplot(8,8,idx,'axis','on')
    %smplot(8,8,idx)
    axis tight
    %axis off
    
    if ndims(sig)==3
        % Take the mean across epochs
        if strcmp(cceps, 'plot3') % NEED TO UPDATE this so that this is an argument for a specific value
            p = plot3(sig(:,idx,1),sig(:,idx,2),sig(:,idx,3),'linewidth',2);
        else
            p = plot(t',mean(sig(:,idx,:),3),'linewidth',2);
        end
    elseif ismatrix(sig)
        % assume that you've already averaged, or just want to plot single
        % epochs
        p = plot(t',sig(:,idx),'linewidth',2);
    else 
        error('dimensions of your signal, sig, must be 2 or 3')
    end
    
    ylim([-150e-6 150e-6])
    if strcmp(cceps,'yes')
        xlim([0 60])      
    end
    
      
    
    % box stim channels, color them
    if ismember(idx,stims)
        ax = gca;
        ax.Box = 'on';
        ax.XColor = CT(:,1);
        ax.YColor = CT(:,1);
        ax.LineWidth = 2;
        p.Color = CT(:,1);
        title(['Chan ',num2str(idx)],'color',CT(:,1))
        
    elseif ismember(idx,chansCCEPs)
        ax = gca;
        ax.Box = 'on';
        ax.XColor = CT(:,3);
        ax.YColor = CT(:,3);
        ax.LineWidth = 2;
        p.Color = CT(:,3);
        title(['Chan ',num2str(idx)],'color',CT(:,3))
        xlabel('time (ms)')
        ylabel('voltage (V)')
        
    else
        ax = gca;
        ax.Box = 'on';
        ax.XColor = CT(:,2);
        ax.YColor = CT(:,2);
        %ax.LineWidth = 2;
        p.Color = CT(:,2);
        %                title(['Chan ',num2str(idx)],'color',CT(:,1))
        axis off
        title(['Chan ',num2str(idx)],'color',CT(:,2))
        
        
    end
end
xlabel('time (ms)')
ylabel('voltage')
legend({'high'})


end