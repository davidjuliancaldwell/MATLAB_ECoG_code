function [phase_at_0,f,Rsquare,FITLINE] = phase_calculation(X,t,smooth_span,f_range,fs,plotIt)

% DJC - 1-25-2017 - function takes in a time x trials matrix , and returns
% matrices representing

t_range = 1./f_range;
t_range = t_range.*fs;

if plotIt
    figure
end

% make matrices to store values over each iteration 
phase_at_0 = zeros(size(X,2),1);
FITLINE = zeros(size(X,1),size(X,2));
Rsquare = zeros(size(X,2),1);
f = zeros(size(X,2),1);

for k = 1:size(X,2)
    sig_ind = X(:,k);

    [pha_a,T_a,amp_a,rsquare_a,fitline] = sinfit(1e6*sig_ind,smooth_span,t_range);

    f_calculated = 1/(T_a/fs);
    length_sig = length(sig_ind);
    x = 1:length_sig;
    a = amp_a.*sin(pha_a+(2*pi*x/T_a));
    
    phase_delivery = mod((pha_a+(length_sig*pi*2/T_a)),(2*pi));

    % save it to matrix 
    phase_at_0(k) = phase_delivery;
    Rsquare(k) = rsquare_a;
    FITLINE(:,k) = fitline;
    f(k) = f_calculated;
%     if raw_sig
%         signal_filt = smooth(sig_ind,smooth_span,'moving',0); % smooth data via moving average
%         signal_filt = signal_filt-median(signal_filt); % DC correction  
%         figure
%         plot(signal_filt)
%         hold on
%         plot(sig_ind)
%         legend({'smoothed signal','raw signal'})
%     end
    
    if plotIt
        plot(t,a,t,1e6*sig_ind)
        legend({'curve fit','original sig'})
        title('Curve fitting')
        set(gca,'fontsize',14);
        pause(1)
    end
end

end
