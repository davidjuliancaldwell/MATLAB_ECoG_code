%%
[~,sta,par] = load_bcidatUI('d:\temp');

%%

bints = downsample(sta.Feature11, par.SampleBlockSize.NumericValue);