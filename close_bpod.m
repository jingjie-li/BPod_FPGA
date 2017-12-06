function  close_bpod( )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
global s
try
fclose(s);
delete(s);
clear global s
fprintf('Goodbye for now\n')
catch
    fprintf('Something Wrong in Closing B-pod connection...\n')
end
end

