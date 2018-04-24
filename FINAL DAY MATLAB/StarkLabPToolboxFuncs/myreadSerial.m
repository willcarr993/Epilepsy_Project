function out = myreadSerial(s)
out=0;
if (ismac)
    DATA = SerialComm( 'read', s, 1 );
    out = length(DATA);
else
    if s.BytesAvailable
        out = fread(s,s.BytesAvailable);
    end
end
%fprintf(1,'Read %d bytes\n',out);


