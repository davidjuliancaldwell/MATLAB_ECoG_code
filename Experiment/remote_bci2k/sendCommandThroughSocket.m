function sendCommandThroughSocket(message, host, port, number_of_retries)

    import java.net.Socket
    import java.io.*

    if (nargin <3)
        number_of_retries = 20; % set to -1 for infinite
    end
    
    retry        = 0;
    msocket = [];
    
    while true

        retry = retry + 1;
        if ((number_of_retries > 0) && (retry > number_of_retries))
            fprintf(1, 'Too many retries\n');
            break;
        end
        
        try
            fprintf(1, 'Retry %d connecting to %s:%d\n', ...
                    retry, host, port);

            % throws if unable to connect
            msocket = Socket(host, port);

            pause(0.1);
            % get the output stream to write
            output_stream = msocket.getOutputStream;
            d_output_stream = DataOutputStream(output_stream);
            pause(0.1);

            % write bytes
            d_output_stream.writeBytes(char(message));
            d_output_stream.flush;
            
            % cleanup
            
            msocket.close;
            break;
            
        catch
            if ~isempty(msocket)
                msocket.close;
            end

            % pause before retrying
            pause(1);
        end
    end
end