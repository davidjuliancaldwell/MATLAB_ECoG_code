% performs average reference of gSignal according to Montage
%   1.4.12 - Tim Blakely tim.blakely@gmail.com

function out = ReferenceCAR(Montage, BadChannels, gSignal)
if nargin == 0
    Montage = 'all';
end

switch char(mat2str(Montage))
    case 'all'
        numChannels = size(gSignal,2);
        numGoodChannels = numChannels - length(BadChannels);
        
        commonAverageReferenceMat = -ones(numChannels);
        
        for i = find(BadChannels < offset+numChannels & BadChannels > offset+1)
            bc = BadChannels(i);
            commonAverageReferenceMat(:,bc) = 0;
            commonAverageReferenceMat(bc,:) = 0;
            commonAverageReferenceMat(bc,bc) = 1;
        end

        for i=1:numChannels
            commonAverageReferenceMat(i,i) = numGoodChannels - 1;
        end
        gSignal = gSignal * commonAverageReferenceMat/numGoodChannels;
    otherwise
        if sum(Montage) > size(gSignal, 2)
            error('Too many electrodes in montage');
        elseif sum(Montage) < size(gSignal,2);
            warning('Reference:Montage', 'Number of electrodes in montage is less than gSiganl, some electrodes NOT being re-referenced');
        end
        offset = 0;
        for numChannels = Montage
            commonAverageReferenceMat = -ones(numChannels);
            
            numGoodChannels = length(setdiff(offset+1:offset+numChannels,BadChannels));

            for i=1:numChannels
                commonAverageReferenceMat(i,i) = numGoodChannels - 1;
            end
            for i = find(BadChannels <= offset+numChannels & BadChannels >= offset+1)
                bc = find([offset+1:offset+numChannels] == BadChannels(i));
                commonAverageReferenceMat(:,bc) = 0;
                commonAverageReferenceMat(bc,:) = 0;
                commonAverageReferenceMat(bc,bc) = 1;
            end
            gSignal(:,offset+1:offset+numChannels) = gSignal(:,offset+1:offset+numChannels) * commonAverageReferenceMat/numGoodChannels;
            offset = offset + numChannels;
        end
end
out = gSignal;
return
        
