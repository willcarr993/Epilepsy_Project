function [cx, keyPressT] = picResponse(screenparms, delay, expinfo, handle)
mismatchOne = KbName('a');
mismatchTwo = KbName('s');
matchOne = KbName('k');
matchTwo = KbName('l');
waitTime = 3.5;
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


while t < waitTime % set waitTime above to be specific for pitch, fact-check, or picture
    t = GetSecs-startSecs;
    
    if t > 1.5
        DrawFormattedText(screenparms.window, '+' , 'center', 'center', [255 255 255]);
        Screen('Flip',screenparms.window);
    end
    
    if handle>0  %if box is installed then wait for button after clearing queue
        
        evt = CedrusResponseBox('GetButtons', handle); %'WaitButtonPress' might work better?
        
        if ~isempty(evt) % if something has been pressed
            
            keyPressT = GetSecs-expinfo.scannerOnTime;
            
            if evt.action == 1 % Only do the following if button is pressed (not released)
                
                cx = evt.button; % response = button number
                cx = cx-4; % to make a left press = 0 and a right press = 1
                
                % TO CHANGE CODE FOR 2 BOXES USE BELOW - could be || not |
                %%% if cx == 2 | 3
                %%% cx = 0
                %%% elseif cx == 4 | 5
                %%% cx = 1
                %%% end
               
                break
            end
        end
        
    else
        
        [keyIsDown, secs, keyCode] = KbCheck;
        pressedKeys = find(keyCode);
        
        if keyCode(mismatchOne) | keyCode(mismatchTwo)
            cx = 0;
            keyPressT = GetSecs-expinfo.scannerOnTime;
            %Snd('Play',sin(1:1:500),2300);
            
        elseif keyCode(matchOne) | keyCode(matchTwo)
            cx = 1;
            keyPressT = GetSecs-expinfo.scannerOnTime;
            %Snd('Play',sin(1:1:500),2300);
            
            
        end
        
        
    end
end

end
