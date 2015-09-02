variances = .01:.1:1;
highmeans = 0.2:0.1:2.0;
meanlabels = cell(length(highmeans),1);

for c = 1:length(highmeans)
    meanlabels{c} = ['upper mean of ' num2str(highmeans(c))];
end

vs = zeros(length(variances), length(highmeans));

for highmean = highmeans
    for variance = variances
        a = random('norm', .1, sqrt(variance), [1000 1]);
        b = random('norm', highmean, sqrt(variance), [1000 1]);

    %     figure;
    %     subplot(211);
    %     xlim([min([a;b]) max([a;b])]);
    %     hist(a,20);
    %     subplot(212);
    %     xlim([min([a;b]) max([a;b])]);
    %     hist(b,20);

%         temp = min(length(a), length(b));
% 
%         aprime = a(1:temp);
%         bprime = b(1:temp);
% 
%         figure;
%         plot(a, b, 'rx');

%         temp = xcorr(a,b,0,'coeff')^2;
%         if ( mean (a) < mean (b) ) temp = -temp;
%         end

        ap = a - mean(a);
        bp = b - mean(b);
        
%         temp = dot(a,b) / (norm(a)*norm(b));
        temp = dot(ap,bp) / (norm(ap)*norm(bp));
        ps(variance == variances, highmean == highmeans) = xcorr(a,b,0,'coeff')^2;
        ws(variance == variances, highmean == highmeans) = temp^2;
        vs(variance == variances, highmean == highmeans) = signedSquaredXCorrValue(a, b);
    end
end

figure, plot(vs, 'b');
hold on; plot(ws, 'r');
% plot(ps,'g');

% figure, plot(variances, vs);
% legend(meanlabels);