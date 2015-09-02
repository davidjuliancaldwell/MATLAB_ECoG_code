%% Nonlinear Regression
% A feed-forward network is trained to perform a nonlinear regression
% between spectral components and cholesterol levels.  The final network
% is analyzed to investigate overall performance.

% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.5.2.4 $  $Date: 2011/05/09 00:58:50 $

%%
% Load inputs X, a 21x264 matrix defining twenty-one spectral measurements
% of 264 blood samples, and targets T, a 3x264 matrix of levels of three
% kinds of cholesterol for each blood sample.

[x,t] = cho_dataset;

%%
% Create a feedforward network with 5 hidden neurons.  We add an input
% processing step that performs principle component analysis on the
% input data and removes those components which account for less
% than 0.1% of the variation.

net = feedforwardnet(5);
net.inputs{1}.processFcns = [{'processpca'} net.inputs{1}.processFcns];
net.inputs{1}.processParams{1}.maxfrac = 0.001;

%%
% Train the network using early stopping.

[net,tr] = train(net,x,t);

%%
% Plot the training, validation and test errors.

plotperform(tr);

%%
% Simulate the trained network.

y = net(x);

%%
% Plot regression analysis for output element 1.

r = zeros(1,3);
m = zeros(1,3);
b = zeros(1,3);

i = 1;
plotregression(y(i,:),t(i,:))
[r(i),m(i),b(i)] = regression(y(i,:),t(i,:));

%%
% Plot regression analysis for output element 2.

i = 2;
plotregression(y(i,:),t(i,:))
[r(i),m(i),b(i)] = regression(y(i,:),t(i,:));

%%
% Plot regression analysis for output element 3.

i = 3;
plotregression(y(i,:),t(i,:))
[r(i),m(i),b(i)] = regression(y(i,:),t(i,:));



displayEndOfDemoMessage(mfilename)
