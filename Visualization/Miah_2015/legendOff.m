function legendOff(handles)

    for c = 1:length(handles)
        h_cur = handles(c);
        
        hAnnotation = get(h_cur,'Annotation');
        hLegendEntry = get(hAnnotation','LegendInformation');
        set(hLegendEntry,'IconDisplayStyle','off')
    end

end