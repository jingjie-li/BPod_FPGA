flushinput(s)
if s.BytesAvailable>0
    a = fread(s, s.BytesAvailable);
    fprintf('the output is %d',a(1));
end