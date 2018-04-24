function [cx, keyPressT] = getResponse(screenparms, delay, expinfo, handle)
RightKey = KbName('RightArrow');
LeftKey = KbName('LeftArrow');

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
s=1;
%%% to make it so that the sentence stays on longer the while and if
%%% functions have to have their variables swapped - but this still means
%%% that subjects might not be able to respond up until the end of
%%% presentation of the sentence/image

%%% can change this to make the response window the same length as the
%%% delay for the pitch or verification

while t < expinfo.maxwait % maxwait is 3
    t = GetSecs-startSecs;
    if t > delay && s==1;
        DrawFormattedText(screenparms.window, '+' , 'center', 'center', [255 255 255]);
        Screen('Flip', screenparms.window);
        s=0;
    end
    if handle>0  %if box is installed then wait for button after clearing queue
        
        evt = CedrusResponseBox('GetButtons', handle); %'WaitButtonPress' might work better?
        
        if ~isempty(evt) % if something has been pressed
            
            keyPressT = GetSecs-expinfo.scannerOnTime;
            
            if evt.action == 1 % Only do the following if button is pressed (not released)
                
                cx = evt.button; % response = button number
                cx = cx-4; % to make a left press = 0 and a right press = 1
                break
            end
        end
        
    else
        
        [keyIsDown, secs, keyCode] = KbCheck;
        pressedKeys = find(keyCode);
        
        if keyCode(LeftKey)
            cx = 0;
            keyPressT = GetSecs-expinfo.scannerOnTime;
            
            break
        elseif keyCode(RightKey)
            cx = 1;
            keyPressT = GetSecs-expinfo.scannerOnTime;
            
            break
            
        end
        
        
    end
end
%Snd('Play',sin(1:1:500),2300);
end
