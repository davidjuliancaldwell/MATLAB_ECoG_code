dsFile = 'ds/fc9643_ud_mot_t_ds.mat'; load(dsFile); controlChannel = 24;
[signals, states, parameters] = load_bcidat([ds.recs(1).dir '\' ds.recs(1).file]);
load([ds.recs(1).dir '\' ds.recs(1).montage]);

signals = double(signals);
signals_car = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);

signals_notch = NotchFilter(signals_car, [60 120 180], parameters.SamplingRate.NumericValue);
% signals_notch = notch(signals_car, [60 120 180], parameters.SamplingRate.NumericValue,4);
signals_bp = BandPassFilter(signals_notch, [75 125], parameters.SamplingRate.NumericValue, 4);
% signals_bp = bandpass(signals_notch, 75, 125, parameters.SamplingRate.NumericValue, 4);
signals_hamp = abs(hilbert(signals_bp));
signals_final = signals_hamp(:,controlChannel);

signals2 = signals_car(:,controlChannel);
% signals2_notch = NotchFilter(signals2, [60 120 180], parameters.SamplingRate.NumericValue, 4);
signals2_notch = notch(signals2, [60 120 180], parameters.SamplingRate.NumericValue, 4);
signals2_bp = bandpass(signals2_notch, 75, 125, parameters.SamplingRate.NumericValue, 4);
signals2_hamp = abs(hilbert(signals2_bp));
signals2_final = signals2_hamp;

%%

figure
ax(1) = subplot(211);
plot(signals_final);

ax(2) = subplot(212);
plot(signals2_final);

linkaxes(ax, 'x');