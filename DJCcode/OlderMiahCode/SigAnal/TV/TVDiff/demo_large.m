% script to demonstrate large-scale example from paper Rick Chartrand, 
% "Numerical differentiation of noisy, nonsmooth data," ISRN
% Applied Mathematics, Vol. 2011, Article ID 164564, 2011.

load largedemodata

%% smoother example

% want figure long enough to show detail
figure( 'Position', [ 100, 380, 1380, 550 ] )

u = TVRegDiff( largescaledata, 40, 1e-1, [], 'large', 1e-8, [], 1, 0 );
% same as u = TVRegDiff( largescaledata, 40, 1e-1, [], 'large', 1e-8 );


%% less smooth example

% want figure long enough to show detail
figure( 'Position', [ 100, 380, 1380, 550 ] )

u = TVRegDiff( largescaledata, 40, 1e-3, [], 'large', 1e-6, [], 1, 0 );
% same as u = TVRegDiff( largescaledata, 40, 1e-3 );

