function shutDown
global ptb3;

if ptb3, ListenChar(0); end
Screen('CloseAll');
fclose('all');
%while KbCheck; end
FlushEvents('keyDown');
