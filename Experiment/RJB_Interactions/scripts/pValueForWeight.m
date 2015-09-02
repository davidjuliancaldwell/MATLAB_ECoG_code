function p = pValueForWeight(weight, distro)
    % assumes distro is pre-sorted    
    N = length(distro);
    
    idx = find(weight>distro, 1, 'first');
    
    if (isempty(idx))
        p = 1;
    else
        p = idx/N;
    end
    
%     p = idx/N;
end