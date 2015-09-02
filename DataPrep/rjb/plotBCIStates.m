function plotBCIStates(states, h)
    if (~exist('h', 'var'))
        h = figure;
    end
    
    figure(h);
    
    plot(states.TargetCode, 'b'); hold on;
    plot(states.ResultCode, 'r');
    plot(states.Feedback, 'g');
    
    legend('target code', 'result code', 'feedback');
    xlabel('samples');
    ylabel('code value');
end