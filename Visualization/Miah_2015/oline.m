function oline(m, b)
    xlims = xlim;
    ylims = ylim;
    
    x = linspace(xlims(1), xlims(2), 10);
    plot(x, m*x+b, 'k');
end