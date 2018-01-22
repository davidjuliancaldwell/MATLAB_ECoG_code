function nntextdemos
% Neural Network Design Textbook Demonstrations
% ---------------------------------------------
% 
% Copyright 1993-2010 Martin T. Hagan and Howard B. Demuth.
% Used by permission.
%
% Neural Network Design Textbook
% by Martin T. Hagan, Howard B. Demuth, Mark H. Beale
%   nntextbook - Neural Network Design textbook information.
%
% General
%   <a href="matlab:doc nnd">nnd</a>        - Splash screen.
%   <a href="matlab:doc nndtoc">nndtoc</a>     - Table of contents.
%   <a href="matlab:doc nnsound">nnsound</a>    - Turn Neural Network Design sounds on and off.
%
% Chapter 2, Neuron Model and Network Architectures
%   <a href="matlab:doc nnd2n1">nnd2n1</a>     - One-input neuron demonstration.
%   <a href="matlab:doc nnd2n2">nnd2n2</a>     - Two-input neuron demonstration.
%
% Chapter 3, An Illustrative Example
%   <a href="matlab:doc nnd3pc">nnd3pc</a>     - Perceptron classification demonstration.
%   <a href="matlab:doc nnd3hamc">nnd3hamc</a>   - Hamming classification demonstration.
%   <a href="matlab:doc nnd3hopc">nnd3hopc</a>   - Hopfield classification demonstration.
%
% Chapter 4, Perceptron Learning Rule
%   <a href="matlab:doc nnd4db">nnd4db</a>     - Decision boundaries demonstration.+
%   <a href="matlab:doc nnd4pr">nnd4pr</a>     - Perceptron rule demonstration.+
%
% Chapter 5, Signal and Weight Vector Spaces
%   <a href="matlab:doc nnd5gs">nnd5gs</a>     - Gram-Schmidt demonstration.
%   <a href="matlab:doc nnd5rb">nnd5rb</a>     - Reciprocal basis demonstration.
%
% Chapter 6, Linear Transformations for Neural Networks
%   <a href="matlab:doc nnd6lt">nnd6lt</a>     - Linear transformations demonstration.
%   <a href="matlab:doc nnd6eg">nnd6eg</a>     - Eigenvector game.
%
% Chapter 7, Supervised Hebbian Learning
%   <a href="matlab:doc nnd7sh">nnd7sh</a>     - Supervised Hebb demonstration.
%
% Chapter 8, Performance Surfaces and Optimum Points
%   <a href="matlab:doc nnd8ts1">nnd8ts1</a>    - Taylor series demonstration #1.
%   <a href="matlab:doc nnd8ts2">nnd8ts2</a>    - Taylor series demonstration #2.
%   <a href="matlab:doc nnd8dd">nnd8dd</a>     - Directional derivatives demonstration.
%   <a href="matlab:doc nnd8qf">nnd8qf</a>     - Quadratic function demonstration.
%
% Chapter 9, Performance Optimization
%   <a href="matlab:doc nnd9sdq">nnd9sdq</a>    - Steepest descent for quadratic function demonstration.
%   <a href="matlab:doc nnd9mc">nnd9mc</a>     - Method comparison demonstration.
%   <a href="matlab:doc nnd9nm">nnd9nm</a>     - Newton's method demonstration.
%   <a href="matlab:doc nnd9sd">nnd9sd</a>     - Steepest descent demonstration.
%
% Chapter 10, Widrow-Hoff Learning
%   <a href="matlab:doc nnd10nc">nnd10nc</a>    - Adaptive noise cancellation demonstration.
%   <a href="matlab:doc nnd10eeg">nnd10eeg</a>   - Electroencephelogram noise cancellation demonstration.
%   <a href="matlab:doc nnd10lc">nnd10lc</a>    - Linear pattern classification demonstration.
%
% Chapter 11, Backpropagation
%   <a href="matlab:doc nnd11nf">nnd11nf</a>    - Network function demonstration.
%   <a href="matlab:doc nnd11bc">nnd11bc</a>    - Backpropagation calculation demonstration.
%   <a href="matlab:doc nnd11fa">nnd11fa</a>    - Function approximation demonstration.
%   <a href="matlab:doc nnd11gn">nnd11gn</a>    - Generalization demonstration.
%
% Chapter 12, Variations on Backpropagation
%   <a href="matlab:doc nnd12sd1">nnd12sd1</a>   - Steepest descent backpropagation demonstration #1.
%   <a href="matlab:doc nnd12sd2">nnd12sd2</a>   - Steepest descent backpropagation demonstration #2.
%   <a href="matlab:doc nnd12mo">nnd12mo</a>    - Momentum backpropagation demonstration.
%   <a href="matlab:doc nnd12vl">nnd12vl</a>    - Variable learning rate backpropagation demonstration.
%   <a href="matlab:doc nnd12ls">nnd12ls</a>    - Conjugate gradient line search demonstration.
%   <a href="matlab:doc nnd12cg">nnd12cg</a>    - Conjugate gradient backpropagation demonstration.
%   <a href="matlab:doc nnd12ms">nnd12ms</a>    - Marquardt step demonstration.
%   <a href="matlab:doc nnd12m">nnd12m</a>     - Marquardt backpropagation demonstration.
%  
% Chapter 13, Associative Learning
%   <a href="matlab:doc nnd13uh">nnd13uh</a>    - Unsupervised Hebb demonstration.
%   <a href="matlab:doc nnd13edr">nnd13edr</a>   - Effects of decay rate demonstration.
%   <a href="matlab:doc nnd13hd">nnd13hd</a>    - Hebb with decay demonstration.
%   <a href="matlab:doc nnd13gis">nnd13gis</a>   - Graphical instar demonstration.
%   <a href="matlab:doc nnd13is">nnd13is</a>    - Instar demonstration.
%   <a href="matlab:doc nnd13os">nnd13os</a>    - Outstar demonstration.
%
% Chapter 14, Competitive Networks
%   <a href="matlab:doc nnd14cc">nnd14cc</a>    - Competitive classification demonstration.
%   <a href="matlab:doc nnd14cl">nnd14cl</a>    - Competitive learning demonstration.
%   <a href="matlab:doc nnd14fm1">nnd14fm1</a>   - 1-D Feature map demonstration.
%   <a href="matlab:doc nnd14fm2">nnd14fm2</a>   - 2-D Feature map demonstration.
%   <a href="matlab:doc nnd14lv1">nnd14lv1</a>   - LVQ1 demonstration.
%   <a href="matlab:doc nnd14lv2">nnd14lv2</a>   - LVQ2 demonstration.
%
% Chapter 15, Grossberg Network
%   <a href="matlab:doc nnd15li">nnd15li</a>    - Leaky integrator demonstration.
%   <a href="matlab:doc nnd15sn">nnd15sn</a>    - Shunting network demonstration.
%   <a href="matlab:doc nnd15gl1">nnd15gl1</a>   - Grossberg layer 1 demonstration.
%   <a href="matlab:doc nnd15gl2">nnd15gl2</a>   - Grossberg layer 2 demonstration.
%   <a href="matlab:doc nnd15aw">nnd15aw</a>    - Adaptive weights demonstration.
%
% Chapter 16, Adaptive Resonance Theory
%   <a href="matlab:doc nnd16al1">nnd16al1</a>   - ART1 layer 1 demonstration.
%   <a href="matlab:doc nnd16al2">nnd16al2</a>   - ART1 layer 2 demonstration.
%   <a href="matlab:doc nnd16os">nnd16os</a>    - Orienting subsystem demonstration.
%   <a href="matlab:doc nnd16a1">nnd16a1</a>    - ART1 algorithm demonstration.
%
% Chapter 17, Stability
%   <a href="matlab:doc nnd17ds">nnd17ds</a>    - Dynamical system demonstration.
%
% Chapter 18, Hopfield Network
%   <a href="matlab:doc nnd18hn">nnd18hn</a>    - Hopfield network demonstration.
%
% See also NNTEXTBOOK, NNDEMOS, NNDATASETS.

% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/05/10 17:24:12 $

help nntextdemos

