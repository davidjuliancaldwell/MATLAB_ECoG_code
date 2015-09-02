% tcp_ip.m
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

classdef tcpip < instr
    %TCP_IP -- this class allows for easy TCP/IP communication in Matlab.
    
    properties
        remoteHost % TCP/IP Host - Ex: '127.0.0.1'
        remotePort % TCP/IP Port - Ex: 22
    end
    
    properties (SetAccess = private, GetAccess = private)
        socket
        inStream
        outStream
    end
    
    methods
        function tcp_ip_obj = tcpip(varargin) % constructor
            % creates a TCP/IP object.
            % USAGE:
            % tcp_ip = tcpip('127.0.0.1', 22)
            tcp_ip_obj = tcp_ip_obj@instr('tcpip', 'connecting');
            
            if nargin==2
                host = varargin{1}; port = varargin{2};
                tcp_ip_obj.socket = java.net.Socket(host, port);
                tcp_ip_obj.remoteHost = host;
                tcp_ip_obj.remotePort = port;
                tcp_ip_obj.inStream = tcp_ip_obj.socket.getInputStream;
                tcp_ip_obj.outStream = tcp_ip_obj.socket.getOutputStream;
                tcp_ip_obj.Status = 'connected';
            end
        end
        function write(tcp_ip_obj, command)
            % Writes a string to the tcp/ip port
            % USAGE:
            % tcp_ip_obj.write('write this string to the port')
            c_bytes = java.lang.String([command sprintf(tcp_ip_obj.Terminator)]).getBytes;
            tcp_ip_obj.outStream.write(c_bytes);
            tcp_ip_obj.outStream.flush;
        end
        function resp = read(tcp_ip_obj)
            % Reads a string from the tcp/ip port
            % USAGE:
            % string_from_port = tcp_ip_obj.read
            num_avail = tcp_ip_obj.inStream.available;
            resp = char(1:num_avail);
            for i = 1:num_avail
                resp(i) = char(tcp_ip_obj.inStream.read);
            end
        end
        function close(tcp_ip_obj)
            % closes the tcp/ip port
            % tcp_ip_obj.close;
            if tcp_ip_obj.Status=='connected'
                tcp_ip_obj.inStream.close;
                tcp_ip_obj.outStream.close;
                tcp_ip_obj.socket.close
            end
        end
    end
end
