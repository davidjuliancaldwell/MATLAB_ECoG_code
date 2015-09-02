function Y = extractAverageInteractions(interactions, tgts, earlies, lates)
    Y = zeros(size(interactions, 1), 9, size(interactions, 3), size(interactions, 4));
    
    isEarly = false(size(tgts));
    isEarly(earlies) = true;
    
    isLate = false(size(tgts));
    isLate(lates) = true;
    
    % all targets all time
    Y(:,1,:,:) = squeeze(mean(interactions,2));

    % up targets all time
    Y(:,2,:,:) = squeeze(mean(interactions(:,tgts==1,:,:),2));
    
    % down targets all time
    Y(:,3,:,:) = squeeze(mean(interactions(:,tgts==2,:,:),2));
    
    % all earlies
    Y(:,4,:,:) = squeeze(mean(interactions(:,isEarly,:,:),2));
    
    % up earlies
    Y(:,5,:,:) = squeeze(mean(interactions(:,isEarly & tgts==1,:,:),2));
    
    % down earlies
    Y(:,6,:,:) = squeeze(mean(interactions(:,isEarly & tgts==2,:,:),2));
    
    % all lates
    Y(:,7,:,:) = squeeze(mean(interactions(:,isLate,:,:),2));
    
    % up lates
    Y(:,8,:,:) = squeeze(mean(interactions(:,isLate & tgts==1,:,:),2));
    
    % down lates
    Y(:,9,:,:) = squeeze(mean(interactions(:,isLate & tgts==2,:,:),2));
end