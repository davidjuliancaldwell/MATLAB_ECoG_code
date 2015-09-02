classdef nnetLayer

% Copyright 2010-2011 The MathWorks, Inc.
  
  properties
    dimensions = [];
    distanceFcn = [];
    distanceParam = [];
    distances = [];
    initFcn = [];
    name = [];
    netInputFcn = [];
    netInputParam = [];
    positions = [];
    range = [];
    size = [];
    topologyFcn = [];
    transferFcn = [];
    transferParam = [];
    userdata = [];
  end
  
  methods
    
    function x = nnetLayer(s)
      x = nnconvert.struct2obj(x,s);
    end
    
    function disp(x)
      isLoose = strcmp(get(0,'FormatSpacing'),'loose');
      str = {};
      if numel(x) == 0
        str{end+1} = '    Empty array of Neural Network Layers.';
      elseif numel(x) > 1
        str{end+1} = ['    Array of ' num2str(numel(x)) ' Neural Network Layers.'];
      else
        str{end+1} ='    Neural Network Layer';
        if (isLoose), str{end+1} = ' '; end
        str{end+1} =[nnlink.prop2link('layer','name') nnstring.str2str(x.name)];
        str{end+1} =[nnlink.prop2link('layer','dimensions') nnstring.int2str(x.dimensions)];
        str{end+1} =[nnlink.prop2link('layer','distanceFcn') nnlink.fcn2strlink(x.distanceFcn)];
        str{end+1} =[nnlink.prop2link('layer','distanceParam') nnlink.paramstruct2str(x.distanceParam)];
        str{end+1} =[nnlink.prop2link('layer','distances') nnstring.num2str(x.distances)];
        str{end+1} =[nnlink.prop2link('layer','initFcn') nnlink.fcn2strlink(x.initFcn)];
        str{end+1} =[nnlink.prop2link('layer','netInputFcn') nnlink.fcn2strlink(x.netInputFcn)];
        str{end+1} =[nnlink.prop2link('layer','netInputParam') nnlink.paramstruct2str(x.netInputParam)];
        str{end+1} =[nnlink.prop2link('layer','positions') nnstring.num2str(x.positions)];
        str{end+1} =[nnlink.prop2link('layer','range') nnstring.num2str(x.range)];
        str{end+1} =[nnlink.prop2link('layer','size') nnstring.num2str(x.size)];
        str{end+1} =[nnlink.prop2link('layer','topologyFcn') nnlink.fcn2strlink(x.topologyFcn)];
        str{end+1} =[nnlink.prop2link('layer','transferFcn') nnlink.fcn2strlink(x.transferFcn)];
        str{end+1} =[nnlink.prop2link('layer','transferParam') nnlink.paramstruct2str(x.transferParam)];
        str{end+1} =[nnlink.prop2link('layer','userdata') '(your custom info)'];
      end
      if (isLoose), str{end+1} = ' '; end
      str = nnlink.filterLinks(str);
      for i=1:length(str), disp(str{i}), end
    end
    
    function s = struct(x)
      s = nnconvert.obj2struct(x);
    end
    
  end
end
