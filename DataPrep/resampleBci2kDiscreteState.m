function resampledState = resampleBci2kDiscreteState(state, oldFs, newFs)

%     if (newFs / oldFs ~= round(newFs / oldFs))
%         error('ratio of newFs to oldFs must be integer value\n');
%     end
%       

    state = double(state);
    del = [0; diff(state)];
    cIdx = find(del ~= 0);
    
    rsCIdx = round(cIdx * newFs / oldFs);
    
    for c = 1:length(rsCIdx)-1
         if(rsCIdx(c) == rsCIdx(c+1))
             rsCIdx(c+1) = rsCIdx(c+1) + 1;
         end
    end
    
    resampledState = state(1) * ones(length(state) * newFs / oldFs, 1);
    
    curVal = resampledState(1);
    
    for c = 1:length(resampledState)
        if (~isempty(rsCIdx) && c == rsCIdx(1))
            curVal = state(cIdx(1));
            
            rsCIdx = rsCIdx(2:end);
            cIdx   = cIdx  (2:end);
        end
        
        resampledState(c) = curVal;
    end
end