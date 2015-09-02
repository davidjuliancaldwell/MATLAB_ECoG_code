function net = formatNet(net,hints)

allWB = nn.wb_indices(net,struct,true);
net = getwb(net,allWB);
