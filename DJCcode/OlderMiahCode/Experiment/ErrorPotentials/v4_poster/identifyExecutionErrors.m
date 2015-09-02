function [hasExeError, exeErrorIndex] = identifyExecutionErrors(ypaths, tgts, targetCounts)
  
% %% temporary
% fbstart = find(t==0)+1;
% fbend = find(t==fbDur);
% ypaths = squeeze(paths(2,:,fbstart:fbend));
% 
% t_temp = 1:20:size(ypaths,2);
% % t_temp = [t_temp size(ypaths,2)];
% ypaths = interp1(t_temp, ypaths(:,t_temp)', 1:size(ypaths, 2))';

    %% for now, let's just concentrate on the two target case, where execution errors are obvious

    hasExeError = zeros(size(ypaths,1), 1);
    exeErrorIndex = nan*hasExeError;

    for trial = 1:size(ypaths,1)
        if (targetCounts(trial) == 2)
            ypath = ypaths(trial, :);

            % starting conditions for an exe error
            %  cursor is in the wrong zone and going the wrong direction for
            %  100 ms (50 samples in this case)

            if tgts(trial) == 1
                inzone = ypath >= 0.5;
                rightdir = [0 diff(ypath)] >= 0;
            else
                inzone = ypath <= 0.5;
                rightdir = [0 diff(ypath)] <= 0;
            end

            temp = ~inzone & ~rightdir;

            consecs = [zeros(1,size(temp, 1));temp.'];
            consecs = consecs(:);
            p = find(~consecs);
            consecs(p) = [0;1-diff(p)];
            consecs = reshape(cumsum(consecs),[],size(temp, 1)).';
            consecs(:,1) = [];

            idx = find(consecs == 50, 1, 'first');

            if (~isempty(idx))
                hasExeError(trial) = 1;
                exeErrorIndex(trial) = idx;

    %             if (tgts(trial) == 1)
    %                 plot(ypath, 'r');
    %             else
    %                 plot(ypath, 'b');
    %             end
    %             
    %             hold on;
    %             plot(idx, ypath(idx), 'ko');
    %             pause;
            end
        else
            % do nothing, we're currently ignoring ntargs > 2

        end
    end
end
