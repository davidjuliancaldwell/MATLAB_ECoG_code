% Neural Network Toolbox Data Functions.
%
% Neural network data
%   nndata       - Create neural network data.
%   catelements  - Concatenate neural network data elements.
%   catsamples   - Concatenate neural network data samples.
%   catsignals   - Concatenate neural network data signals.
%   cattimesteps - Concatenate neural network data timesteps.
%   gadd         - Generalized addition.
%   gdivide      - Generalized right division.
%   getelements  - Get neural network data elements.
%   getsamples   - Get samples from neural network data.
%   getsignals   - Get signals from neural network data.
%   gettimesteps - Get neural network data timesteps.
%   gmultiply    - Generalized multiplication.
%   gnegate      - Generalized negation.
%   gsqrt        - Generalized square root.
%   gsubtract    - Generalized subtraction.
%   meanabs      - Mean of absolute elements of a matrix or matrices.
%   meansqr      - Mean of squared elements of a matrix or matrices.
%   minmax       - Ranges of matrix rows.
%   nncell2mat   - Combines NN cell data into a matrix.
%   nnsize       - Number of neural data elements, samples, time steps and signals.
%   numelements  - Number of elements in neural network data.
%   numfinite    - Number of finite values in neural network data.
%   numnan       - Number of finite values in neural network data.
%   numsamples   - Number of samples in neural network data.
%   numsignals   - Number of signals in neural network data.
%   numtimesteps - Number of samples in neural network data.
%   setelements  - Set neural network data elements.
%   setsamples   - Set neural network data samples.
%   setsignals   - Set neural network data signals.
%   settimesteps - Set neural network data timesteps.
%   sumabs       - Sum of absolute elements of a matrix or matrices.
%   sumsqr       - Sum of squared elements of a matrix or matrices.
%
% Time series
%   preparets    - Prepare time series data for network simulation or training.
%   extendts     - Extends time series data to a given number of timesteps.
%   tapdelay     - Shift neural network time series data for a tap delay.
%   con2seq      - Convert concurrent vectors to sequential vectors.
%   seq2con      - Convert sequential vectors to concurrent vectors.
%   nncorr       - Cross-correlation between neural time series.
%
% Vector/index conversion
%   ind2vec      - Convert indices to vectors.
%   vec2ind      - Transform vectors to indices.
%
% Analyisis
%   confusion    - Classification confusion matrix.
%   regression   - Linear regression.
%   roc          - Receiver operating characteristic.
%
% Plotting
%   plotep       - Plot a weight-bias position on an error surface.
%   plotes       - Plot the error surface of a single input neuron.
%   plotpc       - Plot a classification line on a perceptron vector plot.
%   plotpv       - Plot perceptron input/target vectors.
%   plotv        - Plot vectors as lines from the origin.
%   plotvec      - Plot vectors with different colors.
%   errsurf      - Error surface of single input neuron.
%
% Simulink
%   nndata2sim   - Convert neural network data to Simulink time-series.
%   sim2nndata   - Convert Simulink time-series to neural network data.
%   prunedata    - Prune data for a pruned network
%
% GPU
%   nndata2gpu   - Formats neural data for efficient GPU training or simulation.
%   gpu2nndata   - Reformats neural data back from GPU.
%
% Alternate  row/col representations of samples/timesteps
%   fromnndata   - Convert data from standard neural network cell array form.
%   tonndata     - Convert data to standard neural network cell array form.
%
% Other functions
%   cellmat      - Create a cell array of matrices.
%   combvec      - Create all combinations of vectors.
%   concur       - Create concurrent bias vectors.
%   maxlinlr     - Maximum learning rate for a linear layer.
%   normc        - Normalize columns of matrices.
%   normr        - Normalize rows of matrices.
%   pnormc       - Pseudo-normalize columns of a matrix.
%   quant        - Discretize NN data as multiples of a quantity.
%
% <a href="matlab:help nnet/Contents.m">Main nnet function list</a>.
 
% Copyright 1992-2010 The MathWorks, Inc.
