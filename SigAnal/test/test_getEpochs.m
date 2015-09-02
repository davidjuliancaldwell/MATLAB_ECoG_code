load ('c:/users/jeremiah/research/subjects/7ee6bc/results/finger_twister/pre_data_70_100');

codes = double(sta.StimulusCode);

for code = min(codes):1:max(codes)
    [starts, ends] = getEpochs(codes, code);
    
    temp = zeros(size(codes));
    temp(starts) = max(code,1);
    temp(ends) = -1*max(code,1);
    
    clf;
    plot(double(codes), 'b:'); hold on;
    plot(cumsum(temp), 'r');
    
    drawnow;
    pause(1);
end

