%% Function to format filenames for use in strings (to avoid having the "_" character create a subscript)

function filenameString = filenameForString(filename)

filenameString = strrep (filename, '_', '\_');