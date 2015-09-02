% example of dim use
% if you have an NxT matrix and want to do the running SD throughout time,
% your dim is 2.
%
% ex
%  foo = 1:10
%  runningSD([foo;foo], 5, 1) % returns all zeros
%  runningSD([foo;foo], 5, 2) % returns what you want

function sd = runningSD(data, window, dim)
    if (~exist('dim','var'))
        if(isvector(data))
            dim = find(size(data)==length(data));
        else
            dim = 1;
        end
    end

    sd = zeros(size(data));
    
    for c = 1:size(data,dim)
        st = max(1, c-floor((window-1)/2));
        en = min(size(data,dim), c+ceil((window-1)/2));

%         fprintf('%d to %d\n', st, en);
        
        if (dim == 1)
            sd(c,:) = std(data(st:en,:),0,dim);
        else
            sd(:,c) = std(data(:,st:en),0,dim);
        end
    end
end
