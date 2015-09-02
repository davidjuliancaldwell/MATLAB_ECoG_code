% takes in a vector of electrode counts such as [16 8 8 4 8 8]
% and divides the individual elements if they cross from one amp to another

function gmontage = GugerizeMontage(montage)
    % cycle through the true montage elements
    % if it fits in the current gblock, place it in the montage
    % if not, break it so it does and place the broken part in the montage
    %   continuing on to the unbroken part

    % setup
    space_in_block = 16;
    gmontage = [];
    
    for montage_idx = 1:length(montage)
        entry = montage(montage_idx);
        
        while (entry > 0)
            if (entry > space_in_block)
                gmontage = [gmontage space_in_block];
                entry = entry - space_in_block;
                space_in_block = 16;
            elseif (entry < space_in_block)
                gmontage = [gmontage entry];
                space_in_block = space_in_block - entry;
                entry = 0;
            else % entry == space_in_block
                gmontage = [gmontage entry];
                space_in_block = 16;
                entry = 0;
            end
        end
    end
end