function [div, p] = determineDiv(chg, tgts)
    upinterp = interp1(find(tgts==1), chg(tgts==1), 1:length(tgts), 'linear');
    upinterp = fixnan(upinterp);
    
    dninterp = interp1(find(tgts==2), chg(tgts==2), 1:length(tgts), 'linear');
    dninterp = fixnan(dninterp);
    
    delta = (upinterp-dninterp)';    
%     delta = GaussianSmooth(delta, 20);

    r2 = zeros(size(tgts));    
    
    for trial = 1:length(tgts)
        pre = delta(1:trial);
        post = delta((trial+1):end);

        if (~isempty(pre) && ~isempty(post))
            r2(trial) = signedSquaredXCorrValue(pre, post);
        else
            r2(trial) = 0;            
        end
    end

    [~, div] = max(r2);
    
    [~, p] = ttest2(delta(1:div), delta((div+1):end));        
    
    figure
    subplot(2,1,1);
    gscatter(1:length(tgts), chg(1,:), tgts);
    hold on;
    plot(upinterp, 'ro-');
    plot(dninterp, 'bo-');
    plot(delta, 'k');
    
    subplot(212);
    plot(r2, 'k');
    hold on;
    plot(div, r2(div), 'ko');
    vline(div);
    
    title(num2str(p));
end

function x = fixnan(x)
    early = false(size(x));
    late = false(size(x));
    
    mode = false;
    
    for c = 1:length(x)
        if (~mode && isnan(x(c)))
            early(c) = true;
        elseif (~mode && ~isnan(x(c)))
            mode = true;
        elseif (mode && isnan(x(c)))
            late(c) = true;
        end
    end
    
    earlyval = x(find(~isnan(x),1,'first'));
    x(early) = earlyval;
    
    lateval = x(find(~isnan(x), 1, 'last'));
    x(late) = lateval;
end