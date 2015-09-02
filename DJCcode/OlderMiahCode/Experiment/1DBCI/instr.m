% instr.m
% Copyright Brent Valle 2009
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    For a full copy of the GNU General Public License
%    see .

classdef instr
    properties
        Type
        Terminator = '\r\n'
        Status
    end
    
    methods
        function instr_obj = instr(Type,Status)
            instr_obj.Type = Type;
            instr_obj.Status = Status;
        end
        function response = ask(instr, query)
            instr.write(query);
            response = instr.read;
        end
    end
end
