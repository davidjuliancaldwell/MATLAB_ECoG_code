function Y = extractAverageInteractionsGPU(interactions, tgts, earlies, lates)
    gint = gpuArray(interactions);
    Y = zeros(size(interactions, 1), 9, size(interactions, 3), size(interactions, 4));
    gY = gpuArray(Y);
    
    isEarly = gpuArray(false(size(tgts)));
    isEarly(earlies) = true;
    
    isLate = gpuArray(false(size(tgts)));
    isLate(lates) = true;
    
    % all targets all time
    gY(:,1,:,:) = squeeze(mean(gint,2));

    % up targets all time
    gY(:,2,:,:) = squeeze(mean(gint(:,tgts==1,:,:),2));
    
    % down targets all time
    gY(:,3,:,:) = squeeze(mean(gint(:,tgts==2,:,:),2));
    
    % all earlies
    gY(:,4,:,:) = squeeze(mean(gint(:,isEarly,:,:),2));
    
    % up earlies
    gY(:,5,:,:) = squeeze(mean(gint(:,isEarly & tgts==1,:,:),2));
    
    % down earlies
    gY(:,6,:,:) = squeeze(mean(gint(:,isEarly & tgts==2,:,:),2));
    
    % all lates
    gY(:,7,:,:) = squeeze(mean(gint(:,isLate,:,:),2));
    
    % up lates
    gY(:,8,:,:) = squeeze(mean(gint(:,isLate & tgts==1,:,:),2));
    
    % down lates
    gY(:,9,:,:) = squeeze(mean(gint(:,isLate & tgts==2,:,:),2));
    
    Y = gather(gY);
end