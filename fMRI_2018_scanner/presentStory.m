function [onsetTimes, responses, kp] = presentStory(i, screenparms,expinfo, scriptID, script, scriptCond, imcell, handle, subject)

Screen('TextSize', screenparms.window , expinfo.msgsize);
Screen('TextFont', screenparms.window, screenparms.sansSerifFont);
Screen('TextStyle', screenparms.window, 0);
[xCenter, yCenter] = RectCenter(screenparms.rect);

% set up matrix for timings
onsetTimes=zeros(1,6);
responses =zeros(1,2);
kp = zeros(1,2);

% constants
decisionMsg = '\n\n\n\n\n Negative or Positive?';
jitter = (expinfo.highjitter - expinfo.lowjitter).*rand + expinfo.lowjitter;
iti = (expinfo.highintertrialinterval - expinfo.lowintertrialinterval).*rand + expinfo.lowintertrialinterval;

% specific files

ptr2LeftImg = imcell{scriptID(i),1};
ptr2RightImg = imcell{scriptID(i),2};
pitch = script{scriptID(i),scriptCond(i)}; %works
verified = script{scriptID(i),4}; %always column 4 as its always the same fact check
picDelay = expinfo.picwait;

% Start trial
DrawFormattedText(screenparms.window, 'NEW PITCH!' , 'center', 'center', [255 255 0]);
Screen('Flip', screenparms.window);
onsetTimes(1,1) = GetSecs - expinfo.scannerOnTime; % timer for first onset
WaitSecs(expinfo.getreadytime);

%  present pitch - This doesnt need to change as is identical to previous
%  experiment

[d1, d2, qbox] = DrawFormattedText(screenparms.window, ...
    [pitch], 'center', 'center', [255 255 255], expinfo.wrapat, [], [], 2);
[d1, d2, qbox] = DrawFormattedText(screenparms.window, ...
    [decisionMsg], 'center', 'center', [255 255 0], expinfo.wrapat, [], [], 2);
Screen('Flip',screenparms.window);
onsetTimes(1,2) = GetSecs - expinfo.scannerOnTime;
[responses(1,1), kp(1,1)] = pitchResponse(screenparms, expinfo, handle);

% Put up fixation cross followed by verified version message

DrawFormattedText(screenparms.window, '+' , 'center', 'center', [255 255 255]);
Screen('Flip', screenparms.window);
WaitSecs(jitter-2);% WORKS - creates jitter that has a max of 6 rather than 8

DrawFormattedText(screenparms.window, 'VERIFIED VERSION' , 'center', 'center', [255 0 0]);
Screen('Flip',screenparms.window);
onsetTimes(1,3) = (GetSecs - expinfo.scannerOnTime)-2;
WaitSecs(expinfo.getreadytime); % hold on screen for 500ms

% present verification

[d1, d2, qbox] = DrawFormattedText(screenparms.window, ...
    [verified], 'center', 'center', [255 255 255], expinfo.wrapat, [], [], 2);
Screen('Flip',screenparms.window);
onsetTimes(1,4) = GetSecs - expinfo.scannerOnTime;
WaitSecs(4.5); % reduced 14/11/16


% Put up fixation cross followed by picture check message

DrawFormattedText(screenparms.window, '+' , 'center', 'center', [255 255 255]);
Screen('Flip', screenparms.window);
WaitSecs(jitter); % dont need to account for a response here

DrawFormattedText(screenparms.window, 'PICTURE CHECK' , 'center', 'center', [255 0 0]);
Screen('Flip',screenparms.window);
onsetTimes(1,5) = GetSecs - expinfo.scannerOnTime;
WaitSecs(expinfo.getreadytime);

% present image and get reponse
Screen('PutImage', screenparms.window, ptr2LeftImg,[xCenter-450,yCenter-200,xCenter-50,yCenter+200]);
Screen('PutImage', screenparms.window, ptr2RightImg, [xCenter+50,yCenter-200,xCenter+450,yCenter+200]);
Screen('Flip', screenparms.window);
onsetTimes(1,6) = GetSecs - expinfo.scannerOnTime;
[responses(1,2), kp(1,2)] = picResponse(screenparms, picDelay, expinfo, handle);
DrawFormattedText(screenparms.window, '+' , 'center', 'center', [255 255 255]);
Screen('Flip', screenparms.window);

WaitSecs(iti-2); % as above, allows for extra 2 seconds response

end

