function controlRange = getControlRange(params)
    lowRange = params.FirstBinCenter - params.BinWidth / 2;
    controlRange = [];
    for i=1:size(params.Classifier,1)
        bin = str2double(params.Classifier{i,2});
        controlRange = [controlRange (lowRange:lowRange+params.BinWidth) + (bin-1)*params.BinWidth];
    end
end