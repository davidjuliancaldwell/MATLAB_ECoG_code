function [ptrodes, changed] = projectToHemisphere(trodes, hemi)
    dim = 1;
    ptrodes = trodes;

    if (strcmp(hemi, 'r') || strcmp(hemi, 'right'))
        ptrodes(:, dim) = abs(ptrodes(:, dim));
    elseif (strcmp(hemi, 'l') || strcmp(hemi, 'left'))
        ptrodes(:,dim) = -abs(ptrodes(:,dim));
    else
        error('unknown hemisphere, must be l or r');
    end
    
    changed = any(ptrodes ~= trodes);
end