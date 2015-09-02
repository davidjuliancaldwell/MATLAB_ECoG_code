function types = fcn_types
%NNFCNTYPES List of neural network modular function types

% Copyright 2010 The MathWorks, Inc.

persistent TYPES;
if isempty(TYPES)
  TYPES = { ...
    'nntype.adaptive_fcn'
    'nntype.derivative_fcn'
    'nntype.distance_fcn'
    'nntype.division_fcn'
    'nntype.layer_init_fcn'
    'nntype.learning_fcn'
    'nntype.net_input_fcn'
    'nntype.network_fcn'
    'nntype.network_init_fcn'
    'nntype.performance_fcn'
    'nntype.plot_fcn'
    'nntype.processing_fcn'
    'nntype.search_fcn'
    'nntype.topology_fcn'
    'nntype.training_fcn'
    'nntype.transfer_fcn'
    'nntype.weight_fcn'
    'nntype.weight_init_fcn'
    'nntype.type_fcn'
    };
end
types = TYPES;

% TODO - nn_metric_fcn
