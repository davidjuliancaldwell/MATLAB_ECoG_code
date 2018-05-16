function helperCWTTimeFreqPlot(cfs,time,freq,PlotType,varargin)
%   This function helperCWTTimeFreqPlot is only in support of
%   CWTTimeFrequencyExample and PhysiologicSignalAnalysisExample. 
%   It may change in a future release.

params = parseinputs(varargin{:});


    if strncmpi(PlotType,'surf',1)
        args = {time,freq,abs(cfs).^2};
        surf(args{:},'edgecolor','none');
        view(0,90);
        axis tight;
        shading interp; colormap(parula(128));
        h = colorbar;
        h.Label.String = 'Power';
            if isempty(params.xlab) && isempty(params.ylab)
                xlabel('Time'); ylabel('Hz');
            else
             xlabel(params.xlab); ylabel(params.ylab);
            end
    
            
    elseif strcmpi(PlotType,'contour')
        contour(time,freq,abs(cfs).^2);
        grid on; colormap(parula(128)); 
        h = colorbar;
        h.Label.String = 'Power';
            if isempty(params.xlab) && isempty(params.ylab)
                xlabel('Time'); ylabel('Hz');
            else
             xlabel(params.xlab); ylabel(params.ylab);
            end
            
    elseif strcmpi(PlotType,'contourf')
        contourf(time,freq,abs(cfs).^2);
        grid on; colormap(parula(128)); 
        h = colorbar;
        h.Label.String = 'Power';
            if isempty(params.xlab) && isempty(params.ylab)
                xlabel('Time'); ylabel('Hz');
            else
             xlabel(params.xlab); ylabel(params.ylab);
            end
            
    elseif strncmpi(PlotType,'image',1)
        imagesc(time,freq,abs(cfs).^2);
        colormap(parula(128)); 
        AX = gca;
        h = colorbar;
        h.Label.String = 'Power';
            if isempty(params.xlab) && isempty(params.ylab)
                xlabel('Time'); ylabel('Hz');
            else
                xlabel(params.xlab); ylabel(params.ylab);
            end
    end
    
    if ~isempty(params.PlotTitle)
        title(params.PlotTitle);
    end
        
    
    
    %----------------------------------------------------------------
    function params = parseinputs(varargin)
        
        params.PlotTitle = [];
        params.xlab = [];
        params.ylab = [];
        params.threshold = -Inf;
        
    
        if isempty(varargin)
            return;
        end
        
        Len = length(varargin);
        if (Len==1)
            params.PlotTitle = varargin{1};
        end
    
        if (Len == 3)
            params.PlotTitle = varargin{1};
            params.xlab = varargin{2};
            params.ylab = varargin{3};
        end
           
        
  
 
        