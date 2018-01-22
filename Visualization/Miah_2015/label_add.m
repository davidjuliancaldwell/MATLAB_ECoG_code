function label_add(els,color,msize,plotNames,plotGridLines,names)
% D. Hermes & K.J. Miller 240509
% Dept of Neurology and Neurosurgery, University Medical Center Utrecht
% updated by J. Wander 8/2011

if ~exist('msize','var')
    msize=40; %marker size
end

if ~exist('color','var')
    color = [0.99 0.99 0.99];
end

hold on
p = plot3(els(:,1)*1.01,els(:,2)*1.01,els(:,3)*1.01,'.','MarkerSize',msize,'Color',color);
% for k=1:length(els(:,1))
%     surf(sphere(1);
    
set(p,'clipping','on');
if exist('plotNames') && plotNames ~= 0
    if msize < 40
        warning('Text will look bad, msize < 40');
    end
    for k=1:length(els(:,1))
        if (~exist('names', 'var'))
            txt = num2str(k);
        else
            txt = num2str(names(k));
        end
        t = text(els(k,1)*1.01,els(k,2)*1.01,els(k,3)*1.01,txt,'FontSize',8,'HorizontalAlignment','center','VerticalAlignment','middle');
        set(t,'clipping','on');
    end
end

if exist('plotGridLines') && plotGridLines ~= 0
    cols = floor(size(els,1)/8);
    multipleOfEight = mod(size(els,1),8);
    if multipleOfEight ~= 0
        rows = multipleOfEight;
        cols = 1;
    else
        rows = size(els,1)/cols;
    end
    
    temp = rows;
    rows = cols;
    cols = temp;
    clear temp;
    
    indices = [];
    for r=1:rows-1
        for c=1:cols-1
    %         fprintf('%2i,%2i\n',(((r-1) * cols)+c), (((r-1) * cols)+c+1));
            indices = cat(1,indices,[(((r-1) * cols)+c) (((r-1) * cols)+c+1)]);
        end
        for c=1:cols
    %         fprintf('%2i,%2i\n',(((r-1) * cols)+c), (((r-1+1) * cols)+c));
            indices = cat(1,indices,[(((r-1) * cols)+c) (((r-1+1) * cols)+c)]);
        end
    end
    for c=1:cols-1
    %     fprintf('%2i,%2i\n',(((r-1) * cols)+c), (((r-1+1) * cols)+c));
        indices = cat(1,indices,[(((rows-1) * cols)+c) (((rows-1) * cols)+c+1)]);
    end

    for i=1:length(indices)
        if i == 1 && length(indices) == 2 % hack to get around strips of length 2
            break;
        end
        line(els(indices(i,:),1), els(indices(i,:),2), els(indices(i,:),3),'color',color);
    end
end

