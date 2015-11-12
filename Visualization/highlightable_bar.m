function highlightable_bar(ydata)
  % An example of how to use two bar charts to highlight
  % selected values.
  %
  % Create 2 bar charts.
  h1 = bar(ydata);
  hold on;
  h2 = bar(nan(size(ydata)));
  hold off;
  % You can set whatever properties you like on each of them to make
  % them look as different as you would like.
  h2.FaceColor = 'red';
  % Add a button down listener to each bar chart
  h1.ButtonDownFcn = @btndwn;
  h2.ButtonDownFcn = @btndwn;
  function btndwn(~,evd)
    % Figure out which bar the user clicked on. The eventdata tells us
    % where the mouse was when the click occurred.
    x = round(evd.IntersectionPoint(1));
    % Create 2 YData arrays from the original one. The first
    % has a nan for the selected bar. The second has nans for
    % all of the other bars.
    sel = false(size(ydata));
    sel(x) = true;
    h1.YData = ydata;
    h1.YData(sel) = nan;
    h2.YData = ydata;
    h2.YData(~sel) = nan;
  end
end