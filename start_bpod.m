function  start_bpod( port )
%Using this function to start the B-POD system
%   for example
%   start_bpod('/dev/tty.wchusbserial1420')
%   defaultly, the port is '/dev/tty.wchusbserial1420'
%   by Jingjie Li  jl9249@nyu.edu
if nargin==0
    port = '/dev/tty.wchusbserial1420';
end
global s
s = serial(port);
set(s,'BaudRate',9600,'StopBits',1,'Parity','none','DataBits',8,'InputBufferSize',255);
s.BytesAvailableFcnCount = 1; 
try
    fopen(s);
    fprintf('Oh, Hey, I guess it works\n')
catch
    fprintf('Oh! We cannot open the port %s\n',port)
    fprintf('Maybe there is something connection issue\n')
    clear global s;
end


end

