function spect = getSpectralEstimatesFromStates(sta)
    spect = [];
    for field = fieldnames(sta)'
        if (regexp(field{:}, 'Feature[0-9]*'))
%             fprintf('found state %s, length: %d\n', field{:}, length(sta.(field{:})));
            spect(:,end+1) = sta.(field{:});
        end        
    end
end