function publish_java_window(frame)
%PUBLISH_JAVA_WINDOW Create Figure of Java Window for PUBLISH to capture

% Copyright 2012 The MathWorks, Inc.

s = dbstack;
fcns = {s.name};
if ~isempty(nnstring.first_match('publish',fcns)) && isempty(nnstring.first_match('train',fcns))
  
  if false
    % Convert Java Window to MATLAB Image
    frame.toFront
    drawnow
    com.mathworks.toolbox.nnet.library.gui.nnCapture.capture(frame,'publish_temp');
    im = imread('publish_temp.png');
    delete('publish_temp.png');

    % Display Image in Figure for Publish to capture
    [m,n,c] = size(im);
    f = figure('Units','pixels','Position',[100 100 n m]);
    image(im);
    set(gca,'Position',[0 0 1 1],'box','off','xtick',[],'ytick',[])
    set(f,'NextPlot','new');
    drawnow
  else
    
    
    pane = frame.getContentPane;
    x = pane.getWidth;
    y = pane.getHeight;
    
    fmt = java.awt.image.BufferedImage.TYPE_INT_RGB;
    bi = java.awt.image.BufferedImage(x,y,fmt);
    javaMethodEDT('printAll',pane,bi.getGraphics);

    % Convert the BufferedImage to a 3-D (x,y,3) uint8 array.
    de = bi.getData.getDataElements(0,0,x,y,[]);
    u = typecast(de,'uint8');
    b = reshape(u(1:4:end),x,y)';
    g = reshape(u(2:4:end),x,y)';
    r = reshape(u(3:4:end),x,y)';
    im = cat(3,r,g,b);
    
    [m,n,c] = size(im);
    f = figure('Units','pixels','Position',[100 100 n m]);
    image(im);
    set(gca,'Position',[0 0 1 1],'box','off','xtick',[],'ytick',[])
    set(f,'NextPlot','new');
    drawnow
  end

end
