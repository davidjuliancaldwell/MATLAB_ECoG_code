% script to demonstrate small-scale example from paper Rick Chartrand, 
% "Numerical differentiation of noisy, nonsmooth data," ISRN
% Applied Mathematics, Vol. 2011, Article ID 164564, 2011.

load smalldemodata

noisyabsdata = absdata + 0.05 * randn( size( absdata ) ); 
%results vary  slightly with different random instances

figure,
u = TVRegDiff( noisyabsdata, 500, 0.2, [], 'small', 1e-6, 0.01, 1, 0 );
% defaults mean that u = TVRegDiff( noisyabsdata, 500, 0.2 ); would be the
% same
% Best result obtained after 7000 iterations, though difference is minimal
%
% Set last input to 0 to turn off diagnostics

