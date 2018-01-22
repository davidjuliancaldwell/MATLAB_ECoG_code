% Neural Network Toolbox
% Version 8.0 (R2012b) 20-Jul-2012
%
% Graphical user interface functions.
%   nnstart     - Neural Network Start GUI
%   nctool      - Neural network classification tool
%   nftool      - Neural Network Fitting Tool
%   nntraintool - Neural network training tool
%   nprtool     - Neural network pattern recognition tool
%   ntstool     - NFTool Neural Network Time Series Tool
%   nntool      - Neural Network Toolbox graphical user interface.
%   view        - View a neural network.
%
% Network creation functions.
%   cascadeforwardnet - Cascade-forward neural network.
%   competlayer       - Competitive neural layer.
%   distdelaynet      - Distributed delay neural network.
%   elmannet          - Elman neural network.
%   feedforwardnet    - Feed-forward neural network.
%   fitnet            - Function fitting neural network.
%   layrecnet         - Layered recurrent neural network.
%   linearlayer       - Linear neural layer.
%   lvqnet            - Learning vector quantization (LVQ) neural network.
%   narnet            - Nonlinear auto-associative time-series network.
%   narxnet           - Nonlinear auto-associative time-series network with external input.
%   newgrnn           - Design a generalized regression neural network.
%   newhop            - Create a Hopfield recurrent network.
%   newlind           - Design a linear layer.
%   newpnn            - Design a probabilistic neural network.
%   newrb             - Design a radial basis network.
%   newrbe            - Design an exact radial basis network.
%   patternnet        - Pattern recognition neural network.
%   perceptron        - Perceptron.
%   selforgmap        - Self-organizing map.
%   timedelaynet      - Time-delay neural network.
%
% Using networks.
%   network     - Create a custom neural network.
%   sim         - Simulate a neural network.
%   init        - Initialize a neural network.
%   adapt       - Allow a neural network to adapt.
%   train       - Train a neural network.
%   disp        - Display a neural network's properties.
%   display     - Display the name and properties of a neural network
%   adddelay    - Add a delay to a neural network's response.
%   closeloop   - Convert neural network open feedback to closed feedback loops.
%   formwb      - Form bias and weights into single vector.
%   getwb       - Get all network weight and bias values as a single vector.
%   noloop      - Remove neural network open and closed feedback loops.
%   openloop    - Convert neural network closed feedback to open feedback loops.
%   removedelay - Remove a delay to a neural network's response.
%   separatewb  - Separate biases and weights from a weight/bias vector.
%   setwb       - Set all network weight and bias values with a single vector.
%
% Simulink support.
%   gensim     - Generate a Simulink block to simulate a neural network.
%   setsiminit - Set neural network Simulink block initial conditions
%   getsiminit - Get neural network Simulink block initial conditions
%   neural     - Neural network Simulink blockset.
%
% Training functions.
%   trainb    - Batch training with weight & bias learning rules.
%   trainbfg  - BFGS quasi-Newton backpropagation.
%   trainbr   - Bayesian Regulation backpropagation.
%   trainbu   - Unsupervised batch training with weight & bias learning rules.
%   trainbuwb - Unsupervised batch training with weight & bias learning rules.
%   trainc    - Cyclical order weight/bias training.
%   traincgb  - Conjugate gradient backpropagation with Powell-Beale restarts.
%   traincgf  - Conjugate gradient backpropagation with Fletcher-Reeves updates.
%   traincgp  - Conjugate gradient backpropagation with Polak-Ribiere updates.
%   traingd   - Gradient descent backpropagation.
%   traingda  - Gradient descent with adaptive lr backpropagation.
%   traingdm  - Gradient descent with momentum.
%   traingdx  - Gradient descent w/momentum & adaptive lr backpropagation.
%   trainlm   - Levenberg-Marquardt backpropagation.
%   trainoss  - One step secant backpropagation.
%   trainr    - Random order weight/bias training.
%   trainrp   - RPROP backpropagation.
%   trainru   - Unsupervised random order weight/bias training.
%   trains    - Sequential order weight/bias training.
%   trainscg  - Scaled conjugate gradient backpropagation.
%
% Plotting functions.
%   plotconfusion  - Plot classification confusion matrix.
%   ploterrcorr    - Plot autocorrelation of error time series.
%   ploterrhist    - Plot error histogram.
%   plotfit        - Plot function fit.
%   plotinerrcorr  - Plot input to error time series cross-correlation.
%   plotperform    - Plot network performance.
%   plotregression - Plot linear regression.
%   plotresponse   - Plot dynamic network time-series response.
%   plotroc        - Plot receiver operating characteristic.
%   plotsomhits    - Plot self-organizing map sample hits.
%   plotsomnc      - Plot Self-organizing map neighbor connections.
%   plotsomnd      - Plot Self-organizing map neighbor distances.
%   plotsomplanes  - Plot self-organizing map weight planes.
%   plotsompos     - Plot self-organizing map weight positions.
%   plotsomtop     - Plot self-organizing map topology.
%   plottrainstate - Plot training state values.
%   plotwb         - Plot Hinton diagrams of weight and bias values.
%
% Lists of other neural network implementation functions.
%   nnadapt       - Adapt functions.
%   nnderivative  - Derivative functions.
%   nndistance    - Distance functions.
%   nndivision    - Division functions.
%   nninitlayer   - Initialize layer functions.
%   nninitnetwork - Initialize network functions.
%   nninitweight  - Initialize weight functions.
%   nnlearn       - Learning functions.
%   nnnetinput    - Net input functions.
%   nnperformance - Performance functions.
%   nnprocess     - Processing functions.
%   nnsearch      - Line search functions.
%   nntopology    - Topology functions.
%   nntransfer    - Transfer functions.
%   nnweight      - Weight functions.
%
% Demonstrations, Datasets and Other Resources
%   nndemos     - Neural Network Toolbox demonstrations.
%   nndatasets  - Neural Network Toolbox datasets.
%   nntextdemos - Neural Network Design textbook demonstrations.
%   nntextbook  - Neural Network Design textbook information.

% Copyright 1992-2012 The MathWorks, Inc.

