function controlChannel = getControlChannel(subjid)
    load(sprintf('d:/research/code/gridlab/experiment/1dbci/allpower.m.cache/%s.mat',subjid),'controlChannel');
end