function jdata = jitter(data, frac)
    if(~exist('frac','var'))
        frac = 0.1;
    end
    
    offsets = 2*(rand(size(data)) - .5);
    offsets = offsets * frac*mean(data);
    jdata = data + offsets;
end