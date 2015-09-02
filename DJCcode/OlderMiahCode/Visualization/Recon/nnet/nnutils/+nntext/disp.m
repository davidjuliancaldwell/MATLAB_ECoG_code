function nn_disp(x)

% Copyright 2010-2012 The MathWorks, Inc.

  if iscell(x)
    nn_disp_text(x)
  elseif isstruct(x)
    switch x(1).type
      case 'file_hit'
        nn_disp_file_hit(x)
      case 'text_hit'
      otherwise
    end
  end
end

function nn_disp_text(text)
  for i=1:length(text)
    ti = text{i};
    if isempty(ti)
      disp(' ')
    else
      disp(text{i});
    end
  end
end

function nn_disp_file_hit(hits)
  filenames = cell(1,numel(hits));
  align = 0;
  for i=1:numel(hits)
    [~,fn,ext] = fileparts(hits(i).file);
    filenames{i} = [fn ext];
    align = max(align,length(filenames{i}));
  end
  for i=1:length(hits)
    hit = hits(i);
    name = filenames{i};
    for j=1:length(hit.lines)
      line = num2str(hit.lines(j).line);
      for k=1:length(hit.lines(j).chars)
        char = num2str(hit.lines(j).chars(k));

        link1 = nnlink.str2link(name,...
          ['matlab: opentoline(''' hit.file ''',1,1)']);

        link2 = nnlink.str2link(['line ' line ', char ' char],...
          ['matlab: opentoline(''' hit.file ''',' line ',' char ')']);

        if (j==1) && (k==1)
          indent = nnstring.spaces(align - length(name));
          disp([indent link1 ': ' link2]);
        else
          indent = nnstring.spaces(align);
          disp([indent '  ' link2])
        end
      end
    end
  end
end

