% let's build some system such that the output of the system can be
% described as a noisy combination of lagged versions of the inputs to the
% system and then attempt to use a regression model to identify this transform.

channels = 10;
maxSamples = 200;
trials = 100;
maxLag = 10;

% build the data matrix
input = cell(trials, channels);
output = cell(trials, 1);

nCorrelatedChannels = 4;
correlatedChannels = randperm(channels, nCorrelatedChannels);
mlags = randi(maxLag, [nCorrelatedChannels 1]);

for tr = 1:trials
    samples = randi(maxSamples-round(maxSamples/2), 1)+round(maxSamples/2);
    minput = randn(samples, channels);

    moutput = randn(samples, 1);
    
    for sample = (max(mlags)+1):size(minput, 1)
         base = 0;

         for n = 1:nCorrelatedChannels
             base = base + minput(sample-mlags(n), correlatedChannels(n));
         end

         moutput(sample) = moutput(sample) + base;
    end    
    
    output{tr} = moutput;
    
    for ch = 1:channels
        input{tr,ch} = minput(:, ch);
    end
end

%%
[W,~,R2,f,p] = computeLaggedRegression(input, output, -maxLag:maxLag);
imagesc(1:channels, -maxLag:maxLag, W');

for n = 1:nCorrelatedChannels
    text(correlatedChannels(n), mlags(n), 'o', 'color', 'w');
end

xlabel('channel');
ylabel('lags');

fprintf('if all the white circles line up with all of the red squares, we correctly identified the lagged predictors\n');
