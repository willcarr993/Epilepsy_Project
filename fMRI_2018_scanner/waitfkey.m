% This program forms part of the Working Memory Capacity Battery,
% written by Stephan Lewandowsky, Klaus Oberauer, Lee-Xieng Yang, and Ullrich Ecker.
% The WMCBattery is available online at the website of the Cognitive Science
% Laboratories of the University of Western Australia's School of Psychology:
% http://www.cogsciwa.com ("Software" button on main menu).
% Conditions of Use: Using the WMCBattery is free of charge but the authors
% request that the associated paper be cited (add details later)
% when publications arise out of data collection with the WMCBattery.
% The authors do not guarantee the WMCBattery's functionality.
% This task requires Matlab version 7.5 (2007b) or higher and the
% Psychophysics Toolbox version 2.54 or 3.0.8.

function timeSignal = waitfkey (varargin)
global ptb3

screenparms = varargin{1};
expinfo = varargin{2};
msg = varargin{3};
handle = varargin{4};
triggerButtons = varargin{5}; 

if ptb3
    Screen('TextSize', screenparms.window , expinfo.msgsize);
    Screen('TextFont', screenparms.window, screenparms.sansSerifFont);
    %Screen('FillRect', screenparms.window, screenparms.black);
    %Screen('Flip',screenparms.window);
    DrawFormattedText(screenparms.window, msg , 'center', 'center', screenparms.white);
    %DrawFormattedText centers only approximately. In case of unacceptable
    %deviation, the 'center' argument(s) can be replaced with number
    %(pixel) values, e.g., (..., 'center', 500); [0, 0] indexes the top-left corner
    Screen('Flip', screenparms.window);
else
    expinfo.stimulussize=expinfo.msgsize;
    centertext (screenparms, expinfo, msg, 1);
end

if nargin>=3
    if handle > 0
        %if box is installed then wait for button after clearing queue
        CedrusResponseBox('ClearQueues', handle);
        CedrusResponseBox('FlushEvents', handle); %<--to flush the queue
        while 1
            evt = CedrusResponseBox('GetButtons', handle);  %'WaitButtonPress' might work better?
            
            if ~isempty(evt) && ismember(evt.button, triggerButtons)
                
                           buttons = 1;
            while any(buttons(1,:))
                buttons = CedrusResponseBox('FlushEvents', handle);
            end
 
 %               CedrusResponseBox('ClearQueues', handle);
 %               CedrusResponseBox('FlushEvents', handle);
                break;
            end
        end
    else
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