function [u,s,v] = SVDanal(data,

[u,s,v] = svd(dataStackedGood','econ');

figure
plot(diag(s),'ko','Linewidth',[2])
% to get percentage in mode
subplot(2,1,1) % plot normal
plot(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
title('singular values, fractions')
set(gca,'fontsize',14)

subplot(2,1,2) % plot semilog
semilogy(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
title('singular values, fractions, semilog plot')
set(gca,'fontsize',14)

% look at the modes in space
figure
x = [1:size(dataStackedGood,2)];
plot(x,u(:,1:3),'Linewidth',[2])
title('mode spatial locations'), legend('show')
legend({'mode 1','mode 2','mode 3'});


% look at temporal part - columns of v
figure

plot(v(:,1:3),'Linewidth',[2])
title('Temporal portion of the 3 modes'), legend('show')
legend({'mode 1','mode 2','mode 3'});

end