function [cx, keyPressT] = pitchResponse(screenparms, expinfo, handle)
one = KbName('a');
two = KbName('s');
three = KbName('k');
four = KbName('l');

waitTime = 6.5;
if handle>0
    CedrusResponseBox('ClearQueues', handle);
    CedrusResponseBox('FlushEvents', handle);
else
    while KbCheck; end
    
end

cx = -1; % incase no key is pressed
keyPressT = -1; % incase no key is pressed
startSecs = GetSecs; % initialize clock with current time
t=0;
%s=1;


while t < waitTime % set waitTime above to be specific for pitch, fact-check, or picture
    t = GetSecs-startSecs;
    
    if t > 4.5
        DrawFormattedText(screenparms.window, '+' , 'center', 'center', [255 255 255]);
        Screen('Flip',screenparms.window);
    end
    
    if handle>0  %if box is installed then wait for button after clearing queue
        
        %%% THIS NEEDS TO BE CHANGED TO REFLECT NEW SCALE-BASED
        %%% RESPONSE!!!!!!!
        %%% evt.buttons: 2-5 (left to right)
        
        evt = CedrusResponseBox('GetButtons', handle); %'WaitButtonPress' might work better?
        % evt = CedrusResponseBox('WaitButtonPress', handle);
        
        if ~isempty(evt) % if something has been pressed
            
            keyPressT = GetSecs-expinfo.scannerOnTime;
            
            if evt.action == 1 % Only do the following if button is pressed (not released)
                
                cx = evt.button; % response = button number
                cx = cx-1; % to make it so that 2=1, 3=2 and so on
                
                
                break
            end
        end
        
    else
        
        [keyIsDown, secs, keyCode] = KbCheck;
        pressedKeys = find(keyCode);
        
        if keyCode(one);
            cx = 1;
            keyPressT = GetSecs-expinfo.scannerOnTime;
            
        elseif keyCode(two);
            cx = 2;
            keyPressT = GetSecs-expinfo.scannerOnTime;
            
        elseif keyCode(three);
            cx = 3;
            keyPressT = GetSecs-expinfo.scannerOnTime;
            
        elseif keyCode(four);
            cx = 4;
            keyPressT = GetSecs-expinfo.scannerOnTime;
            
        end
        
        
    end
end

end
