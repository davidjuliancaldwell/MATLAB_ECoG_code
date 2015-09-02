% displays 22 dof cyberglove traces from BCI2000 format recordings
%   1.4.12 - Jeremiah Wander jdwander@gmail.com

function plotCyber(sta)
    figure;
    
    if(isfield(sta, 'Cyber1'))
        cyberType = 'Cyber';
    elseif(isfield(sta, 'rCyber1'))
        cyberType = 'rCyber';
    elseif(isfield(sta, 'lCyber1'))
        cyberType = 'lCyber';
    else
        error('unknown cyberglove recording type');
    end
    
    tot = 0;
    for i=1:22
        eval(sprintf('tot = tot + max(sta.%s%i);',cyberType,i));
    end
    lift = tot/22;
    
    for i=1:22
        eval(sprintf('plot(double(sta.%s%i) + %i - mean(sta.%s%i));', cyberType, i, i*100, cyberType, i));
        
        if (i == 1) 
            hold on;
        end
    end
    
    hold off;
end