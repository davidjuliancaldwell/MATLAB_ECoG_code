load exampleMontage.mat
dataFilesNeededToPlot = {'tutorialdata.mat'};

PlotCorticalDisplay('38e116','r',Montage,dataFilesNeededToPlot,@c_TutorialCallback,[1 5 17 21]);