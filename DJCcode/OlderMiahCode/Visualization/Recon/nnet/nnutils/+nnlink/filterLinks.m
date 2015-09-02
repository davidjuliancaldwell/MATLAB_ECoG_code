function str = filterLinks(str,flag)

if nargin < 2, flag = ~feature('hotlinks'); end
if flag
  if ischar(str)
    starts = strfind(str,'<a href=');
      for start = fliplr(starts)
        middle = strfind(str(start:end),'">') + (start-1);
        stop = strfind(str(middle:end),'</a>') + (middle-1);
        str = str([1:(start-1),(middle+2):(stop-1),(stop+4):end]);
      end
  elseif iscell(str)
    for i=1:length(str)
      str{i} = nnlink.filterLinks(str{i},true);
    end
  end
end
