% let's build some system such that the output of the system can be
% described as a noisy combination of lagged versions of the inputs to the
% system and then attempt to use an AR model to identify this transform.

chans = 64;
samples = 1e4;
maxLag = 30;

input = randn(samples, chans);

nCorrelatedChannels = 4;
correlatedChannels = randperm(chans, nCorrelatedChannels);
mlags = randi(maxLag, [nCorrelatedChannels 1]);

output = randn(samples, 1);

for sample = (max(mlags)+1):size(input, 1)
     base = 0;
     
     for n = 1:nCorrelatedChannels
         base = base + input(sample-mlags(n), correlatedChannels(n));
     end
     
     output(sample) = output(sample) + base;
end

%% verify we've generated what we think ...

[peaks, lags] = xcorr(input(:,correlatedChannels(1)), output, 2*maxLag, 'coeff');
plot(lags, peaks);
title(sprintf('should see a lag at -%d', mlags(1)))
vline(-mlags(1));

%% now use a regression model to estimate these parameters

% this is the unlagged regression model, and should fail
[b, bint, r, rint, stats] = regress(output, [ones(size(input, 1), 1), input]);
fprintf('unlagged regression exhibited an R^2 of %f\n', stats(1));

% now try it with lags
consideredLags = -maxLag:maxLag;
laggedinput = lagmatrix(input, consideredLags);
[b, bint, r, rint, stats] = regress(output, [ones(size(input, 1), 1), laggedinput]);
fprintf('lagged regression exhibited an R^2 of %f\n', stats(1));

% unfold the weights
b(1) = []; % drop the constant term
B = reshape(b, chans, length(consideredLags))';
imagesc(1:chans, consideredLags, B);

for n = 1:nCorrelatedChannels
    text(correlatedChannels(n), mlags(n), 'o', 'color', 'w');
end

xlabel('channel');
ylabel('lags');

[mlags'; correlatedChannels]

fprintf('if all the white circles line up with all of the red squares, we correctly identified the lagged predictors\n');



