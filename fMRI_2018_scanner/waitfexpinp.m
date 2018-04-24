function timeSignal = waitfexpinp(varargin)
global ptb3

screenparms = varargin{1};
expinfo = varargin{2};
msg = varargin{3};
handle = varargin{4};
triggerButtons = varargin{5}; 

if ptb3
    Screen('TextSize', screenparms.window , expinfo.msgsize);
    Screen('TextFont', screenparms.window, screenparms.sansSerifFont);
    DrawFormattedText(screenparms.window, msg , 'center', 'center', screenparms.white);
    Screen('Flip', screenparms.window);
else
    expinfo.stimulussize=expinfo.msgsize;
    centertext (screenparms, expinfo, msg, 1);
end

if nargin>=3
        while KbCheck; end
        while 1
            [keyIsDown,timeSecs,keyCode] = KbCheck;
            if keyCode(KbName('f12'))
                error('User terminated fMRImisinfo script');
                shutDown;
            end
            
            if keyIsDown
                c = KbName(keyCode);
                while KbCheck; end
                if strcmp(c,'space')
                    break;
                end
            end
        end
    end
    cls(screenparms);
    timeSignal = GetSecs;
    %while KbCheck; end
end