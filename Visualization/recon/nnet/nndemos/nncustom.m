%NNCUSTOM List of functions to use as templates for custom functions
%
% Use custom neural network functions to research new neural algorithms.
% 
% WARNING: Custom functions may need to be updated to remain compatible
% with future versions of Neural Network Toolbox software.  These functions
% must support version specific implementation details.
%
% WARNING, Version 8.0 (R2012b):
% Custom processing, weight, net input, transfer, performance, distance
% training and search functions created prior to R2012b must to be updated.
%
% Network Creation Functions
%   Use <a href="matlab:doc feedforwardnet">feedforwardnet</a> as a template.
%
% Input and Output Processing Functions
%   Functions created before R2012b must be updated.
%   Use <a href="matlab:doc mapminmax">mapminmax</a> and its package of subfunctions +mapminmax as templates.
%
% Weight Functions
%   Functions created before R2012b must be updated.
%   Use <a href="matlab:doc dotprod">dotprod</a> and its package of subfunctions +dotprod as templates.
%
% Net Input Functions
%   Functions created before R2012b must be updated.
%   Use <a href="matlab:doc netsum">netsum</a> and its package of subfunctions +netsum as templates.
%
% Transfer Functions
%   Functions created before R2012b must be updated.
%   Use <a href="matlab:doc tansig">tansig</a> and its package of subfunctions +tansig as templates.
%
% Performance functions
%   Functions created before R2012b must be updated.
%   Use <a href="matlab:doc mse">mse</a> and its package of subfunctions +mse as templates.
%
% Distance Functions
%   Functions created before R2012b must be updated. 
%   Use <a href="matlab:doc dist">dist</a> and its package of subfunctions +dist as templates.
%
% Topology Function
%   Use <a href="matlab:doc hextop">hextop</a> as a template.
%
% Network Initialization Functions
%   Use <a href="matlab:doc intlay">initlay</a> as a template.
%
% Layer Initialization Functions
%   Use <a href="matlab:doc initnw">initnw</a> as a template.
%
% Weight/Bias Initialization Functions
%   Use <a href="matlab:doc rands">rands</a> as a template.
%
% Data Division Functions
%   Use <a href="matlab:doc dividerand">dividerand</a> as a template.
%
% Neural Network Training
%   Training functions created before R2012b must be updated.
%   Use <a href="matlab:doc trainlm">trainlm</a>, <a href="matlab:doc trainscg">trainscg</a> or any other training function as a template.
%   Training functions have a subfunction called "train_network" which
%   takes these arguments:
%     archNet - original network in standard neural network object form.
%       Do not alter this object.
%     rawData - original data as a structure. Do not alter this structure.
%     calcLib - a calculation library that encapsulates the training data
%       and calculation details required for efficient calculations on a
%       CPU, GPU or parallel workers.  Use its properties and methods to
%       perform basic operations such as getting/setting network weights,
%       type "help nnCalcLib" for a summary of its properties and methods.
%     calcNet - the neural network formatted for efficient calculations
%       on CPU, GPU or parallel workers.  Do not use this value directly,
%       use it with calcLib method calls.  You may create multiple copies
%       of calcNet, for instance, if you need to create a temporary
%       network to test before deciding whether to accept it.
%     tr - the training record.
%   If your custom training function is to support parallel workers it must
%   do the following, as demonstrated in trainlm and trainscg and other
%   training functions:
%     1) Wrap computations which are to run on the main worker within a
%        "if calcLib.isMainWorker" block.
%     2) Calls to calcLib methods should NOT occur in the
%     calcLib.isMainWorker blocks as these operations need to happen
%     in parallel, even though the result will be returned (and is only
%     valid) on the main worker.
%     3) Any if/else, for-loop, or while-loop blocks which contain a call
%     to calcLib must occur outside of calcLib.isMainWorker blocks
%     so that all workers can reach the calcLib calls.  However code within
%     the if/else, for and while blocks besides the calcLib calls may be
%     wrapped in an "if calcLib.isMainWorker" clause.
%     4) Flags used to control if/else, for and while clauses can be
%     calculated within "if calcLib.isMainWorker" clauses, but they
%     must then be transmitted to all workers using labBroadcast so that
%     all workers follow the same path through the training code.
%     For instance, a boolean value "stop" may be calculated in an
%     "if calcLib.isMainWorker" block, but should then be transmitted
%     to all other workers with "stop = labBroadcast(mainWorkerInd,stop)"
%     before an "if stop,..." clause is executed, so either all the workers
%     execute the if clause, or none of them do.  I.e. the workers follow
%     the same path through the if clause. 
%
% Search Functions
%   Search functions created before R2012b must be updated.
%   Use <a href="matlab:doc srchbac">srchbac</a> as a template.
%   Search functions must handle calcLib, calcNet arguments, and optionally
%   support parallel computing with the same rules as training functions.
%
% Network Adaptation Functions
%   Use <a href="matlab:doc adaptwb">adaptwb</a> as a template.
%
% Weight/Bias Learning Functions
%  Use <a href="matlab:doc learngd">learngd</a> as a template.
%
% Plotting Functions
%   Use <a href="matlab:doc plotfit">plotfit</a> as a template.
%
% WARNING: Custom functions may need to be updated to remain compatible
% with future versions of Neural Network Toolbox software.  These functions
% must support version specific implementation details.
%
% WARNING, Version 8.0 (R2012b):
% Custom processing, weight, net input, transfer, performance, distance
% training and search functions created prior to R2012b must to be updated.
