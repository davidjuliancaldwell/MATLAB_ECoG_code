classdef nnCalcLib

% Copyright 2012 The MathWorks, Inc.
  
  properties (SetAccess = private, GetAccess = private)
    calcMode 
    calcData
    calcHints
  end
  
  properties (SetAccess = private, GetAccess = public)
    isParallel
    isActiveWorker
    isMainWorker
    mainWorkerInd
  end
  
  methods
    
    function lib = nnCalcLib(cm,cd,ch)
      lib.calcMode = cm;
      lib.calcData = cd;
      lib.calcHints = ch;
      lib.isParallel = cm.isParallel;
      lib.isActiveWorker = cm.isActiveWorker;
      lib.isMainWorker = cm.isMainWorker;
      lib.mainWorkerInd = cm.mainWorkerInd;
    end
    
    function wb = getwb(lib,calcNet)
      wb = lib.calcMode.getwb(calcNet,lib.calcHints);
    end
    
    function calcNet = setwb(lib,calcNet,wb)
      calcNet = lib.calcMode.setwb(calcNet,wb,lib.calcHints);
    end
    
    % function pc
    
    % function pd
    
    function [Y,Af] = y(lib,calcNet)
      if nargout == 2
        [Y,Af] = lib.calcMode.y(calcNet,lib.calcData,lib.calcHints);
      else
        Y = lib.calcMode.y(calcNet,lib.calcData,lib.calcHints);
        Af = [];
      end

      % Unflatten if necessary
      if lib.isActiveWorker && lib.calcHints.isComposite
        if lib.calcHints.doFlattenTime
          Yflat = Y;
          Y = cell(lib.calcHints.numOutputs,lib.calcHints.TSu);
          for i=1:lib.calcHints.numOutputs
            Y(i,:) = mat2cell(Yflat{i},lib.calcHints.outputSizes(i),ones(1,lib.calcHints.TSu)*lib.calcData.Qu);
          end
        end
      elseif lib.isMainWorker
        if (lib.calcHints.doFlattenTime)
          Yflat = Y;
          Y = cell(lib.calcHints.numOutputs,lib.calcHints.TSu);
          for i=1:lib.calcHints.numOutputs
            Y(i,:) = mat2cell(Yflat{i},lib.calcHints.outputSizes(i),ones(1,lib.calcHints.TSu)*lib.calcHints.Qu);
          end
        end
      end
    end
    
    function [trainPerf,trainN] = trainPerf(lib,calcNet)
      [trainPerf,trainN] = lib.calcMode.trainPerf(calcNet,lib.calcData,lib.calcHints);
      if lib.isMainWorker
        if lib.calcHints.perfNorm
          Ne = max(1,trainN);
          trainPerf = trainPerf / Ne;
        end
        reg = lib.calcHints.regularization; 
        if (reg > 0)
          wb = lib.calcMode.getwb(calcNet,lib.calcHints);
          perfreg = lib.calcHints.perfWB(wb,lib.calcHints.perfParam);
          if lib.calcHints.perfNorm
            Nwb = max(1,numel(wb));
            perfreg = perfreg / Nwb;
          end
          trainPerf = reg*perfreg + (1-reg)*trainPerf;
        end
      end
    end
    
    function [trainPerf,valPerf,testPerf,trainN,valN,testN] = ...
      trainValTestPerfs(lib,calcNet)
      [trainPerf,valPerf,testPerf,trainN,valN,testN] = ...
        lib.calcMode.trainValTestPerfs(calcNet,lib.calcData,lib.calcHints);
      if lib.isMainWorker
        if lib.calcHints.perfNorm
          Ne = max(1,trainN);
          trainPerf = trainPerf / Ne;
          valPerf = valPerf / valN;
          testPerf = testPerf / testN;
        end
        reg = lib.calcHints.regularization; 
        if (reg > 0)
          wb = lib.calcMode.getwb(calcNet,lib.calcHints);
          perfreg = lib.calcHints.perfWB(wb,lib.calcHints.perfParam);
          if lib.calcHints.perfNorm
            Nwb = numel(wb);
            perfreg = perfreg / Nwb;
          end
          trainPerf = reg*perfreg + (1-reg)*trainPerf;
          valPerf = reg*perfreg + (1-reg)*valPerf;
          testPerf = reg*perfreg + (1-reg)*testPerf;
        end
      end
    end

    function [gWB,trainPerf,trainN] = grad(lib,calcNet)
      [gWB,trainPerf,trainN] = lib.calcMode.grad(calcNet,lib.calcData,lib.calcHints);
      if lib.isMainWorker
        if lib.calcHints.perfNorm
          Ne = max(1,trainN);
          gWB = gWB / Ne;
          trainPerf = trainPerf / Ne;
        end
        reg = lib.calcHints.regularization; 
        if (reg > 0)
          wb = lib.calcMode.getwb(calcNet,lib.calcHints);
          perfreg = lib.calcHints.perfWB(wb,lib.calcHints.perfParam);
          gWBreg = lib.calcHints.dPerfWB(wb,lib.calcHints.perfParam);
          if lib.calcHints.perfNorm
            Nwb = max(1,numel(wb));
            perfreg = perfreg / Nwb;
            gWBreg = gWBreg / Nwb;
          end
          trainPerf = reg*perfreg + (1-reg)*trainPerf;
          gWB = reg*gWBreg + (1-reg)*gWB;
        end
      end
    end

    function [trainPerf,valPerf,testPerf,gWB,gradient,trainN,valN,testN] ...
      = perfsGrad(lib,calcNet)
      [trainPerf,valPerf,testPerf,gWB,trainN,valN,testN] = ...
        lib.calcMode.perfsGrad(calcNet,lib.calcData,lib.calcHints);
      if lib.isMainWorker
        if lib.calcHints.perfNorm
          Ne = max(1,trainN);
          gWB = gWB / Ne;
          trainPerf = trainPerf / Ne;
          valPerf = valPerf / valN;
          testPerf = testPerf / testN;
        end
        reg = lib.calcHints.regularization; 
        if (reg > 0)
          wb = lib.calcMode.getwb(calcNet,lib.calcHints);
          perfreg = lib.calcHints.perfWB(wb,lib.calcHints.perfParam);
          gWBreg = lib.calcHints.dPerfWB(wb,lib.calcHints.perfParam);
          if lib.calcHints.perfNorm
            Nwb = max(1,numel(wb));
            perfreg = perfreg / Nwb;
            gWBreg = gWBreg / Nwb;
          end
          trainPerf = reg*perfreg + (1-reg)*trainPerf;
          valPerf = reg*perfreg + (1-reg)*valPerf;
          testPerf = reg*perfreg + (1-reg)*testPerf;
          gWB = reg*gWBreg + (1-reg)*gWB;
        end
        if (nargout >= 5)
          gradient = sqrt(sum(gWB.^2));
        end
      elseif (nargout >= 5)
        gradient = [];
      end
    end
    
    function [trainPerf,valPerf,testPerf,JE,JJ,gradient,trainN,valN,testN] ...
      = perfsJEJJ(lib,calcNet)
      [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = ...
        lib.calcMode.perfsJEJJ(calcNet,lib.calcData,lib.calcHints);
      if lib.isMainWorker
        if lib.calcHints.perfNorm
          Ne = max(1,trainN);
          JE = JE / Ne;
          JJ = JJ / Ne;
          trainPerf = trainPerf / Ne;
          valPerf = valPerf / valN;
          testPerf = testPerf / testN;
        end
        reg = lib.calcHints.regularization; 
        if (reg > 0)
          wb = lib.calcMode.getwb(calcNet,lib.calcHints);
          perfreg = sum(-2*wb); % MSE or SSE
          Ereg = wb; % Jacobian has opposite sign to gradient
          JEreg = Ereg; % Identity * Ereg
          JJreg = eye(numel(wb)); % Identity * Identity
          if lib.calcHints.perfNorm
            Nreg = max(1,numel(wb));
            perfreg = perfreg / Nreg;
            JEreg = JEreg / Nreg;
            JJreg = JJreg / Nreg;
          end
          trainPerf = reg*perfreg + (1-reg)*trainPerf;
          valPerf = reg*perfreg + (1-reg)*valPerf;
          testPerf = reg*perfreg + (1-reg)*testPerf;
          JE = reg*JEreg + (1-reg)*JE;
          JJ = reg*JJreg + (1-reg)*JJ;
        end
        if nargout >= 6
          gradient = 2*sqrt(sum(JE.^2));
        end
      elseif (nargout >=6 )
        gradient = [];
      end
    end
    
  end
end

