s=serial('/dev/tty.wchusbserial1420');
set(s,'BaudRate',9600,'StopBits',1,'Parity','none','DataBits',8,'InputBufferSize',255);
s.BytesAvailableFcnCount = 1; 
fopen(s);
%% open output
flushinput(s)
fwrite(s,bin2dec('10100000'));
%a = fread(s, s.BytesAvailable);
a = fread(s, 1);
fprintf('the output is %d\n',a(1));
%% close output
fwrite(s,bin2dec('10100011'));
%a=fread(s,1)
%% close and clear
fclose(s);
delete(s);
clear s