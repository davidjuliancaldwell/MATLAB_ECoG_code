% test_windowedAverage

%% all real test
% numsigs = 5;
% siglen  = 10;
% 
% for c = 1:numsigs
%     sig(:,c) = sin(2*pi*50*(0.001:0.001:siglen));
% end
% 
% avs = windowedAverage(sig, 10);

sig = [];
for c = 1:40
    if (mod(c,2) == 0)
        sig = [sig zeros(1,100)];
    else
        sig = [sig ones(1,100)];
    end
end
sig = sig';

nums = unifrnd(0, 1, 4000, 1);

sig(nums > 0.9) = NaN;

avs = windowedAverage(sig, 5);
figure, ax(1) = subplot(211); plot(sig); hold on;
ax(2) = subplot(212);
plot(avs, 'r');

linkaxes(ax,'x');