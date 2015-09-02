function stateValues = extractStatesMatching(stateStruct, matchStr)
    stateValues = [];
    
    for field = fieldnames(stateStruct)'
        if (regexp(field{:}, matchStr))
%             fprintf('%s\n', field{:});
            stateValues(:, end+1) = stateStruct.(field{:});
        end        
    end
end