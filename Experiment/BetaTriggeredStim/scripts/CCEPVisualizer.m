classdef CCEPVisualizer < handle
    properties
        chans;
        nchans;
        figurehandle;
        dim1;
        dim2;
        t;
        tref;
        
        data;
    end  
    methods
        function this = CCEPVisualizer(chans, t, tref)
            
            this.chans = chans;
            this.nchans = length(chans);            
            this.figurehandle = figure;            
%             [this.dim1, this.dim2] = subplotDims(nchans);
            this.dim1 = ceil(sqrt(this.nchans));
            this.dim2 = this.dim1;
            
            this.data = cell(this.nchans, 1);
            this.t = t;
            this.tref = tref;
        end
        
        function reset(this)
            this.data = cell(this.nchans, 1);
            this.cleardisplay();
        end
        
        function cleardisplay(this)
            clf(this.figurehandle);
            for c = 1:this.nchans
                subplot(this.dim1, this.dim2, c); 
            end           
        end
        
%         function autoscale(this)
%             
%         end
        
        function update(this, newdata)
            % newdata should be nchans x datalength,
            % datalength, at least in this dumb iteration should be the
            % same as all previously seen data
            
            % clear the display
            this.cleardisplay();
            
            % add the data to the model
            for c = 1:this.nchans
                if (size(newdata, 2) > length(this.t))
                    this.data{c}(end+1, :) = newdata(c, 1:length(this.t));
                else
                    this.data{c}(end+1, :) = NaN*this.t;
                    this.data{c}(end+1, 1:size(newdata, 2)) = newdata(c, :);
                end
            end
            
            % draw with the new data
            this.draw();
        end
        
        function draw(this)
            for c = 1:this.nchans
                subplot(this.dim1, this.dim2, c);
                plot(this.t, this.data{c}', 'color', [0.5 0.5 0.5]);
                hold on;
                
                mu = nanmean(this.data{c});
                plot(this.t, nanmean(this.data{c}, 1), 'r', 'linew', 2);
                                
                mu(~this.tref)=0;
                [upeak, uloc] = findpeaks(mu);
                [dpeak, dloc] = findpeaks(-mu);
                
%                 hline([upeak uloc 0], 'g');
%                 plot([min(this.t) max(this.t)], [upeak upeak], 'g:');
%                 lowest = nanmin(nanmin(this.data{c}(:, this.tref)));
%                 highest = nanmax(nanmax(this.data{c}(:, this.tref)));
                                
                ylim([-100e-6 100e-6]); %Modified DJC from -100 to 100 8/24/2015
%                 ylim([lowest highest]);
                xlim([min(this.t) max(this.t)]);
                title(num2str(this.chans(c)));
            end
        end
    end
end