function [Answer] = DoPerceptualBaselineScanner(window, t_start, talpha, falpha)
% This function will put a fixation up on the screen and run one trial for
% either study or test (and either test phase).

% Declare the persistent variables.  These will remain across calls to the
% function and let us adjust the alpha of the boxes to be tailored to the
% subject.


path('StarkLabPToolboxFuncs',path);  % Add subdir w/toolbox funcs to path

[XWinsize, YWinsize] = Screen('WindowSize',window); % Get size of window

 % Create basic noise background
bkgnoise = (rand(YWinsize,XWinsize) > 0.5) * 128;
[tex] = Screen('MakeTexture', window, bkgnoise);
Screen('DrawTexture', window, tex);

% Setup order and positions of boxes
order = randperm(2);
tbox = order(1);
fbox = order(2);
bsize = YWinsize / 10 - 1;
stepsize = XWinsize / 3;

% Draw brightened target box
target = (rand(YWinsize,XWinsize) > (0.5 - talpha)) * 180;
tex2=Screen('MakeTexture', window, target);
bpos = [tbox*stepsize YWinsize/2 tbox*stepsize+bsize YWinsize/2+bsize];
bpos = bpos - (bsize/2);
Screen('DrawTexture', window, tex2, [], bpos);

% Draw brightened foil box
foil = (rand(YWinsize,XWinsize) > (0.5 - falpha)) * 180;
tex3=Screen('MakeTexture', window, foil);
bpos = [fbox*stepsize YWinsize/2 fbox*stepsize+bsize YWinsize/2+bsize];
bpos = bpos - (bsize/2);
Screen('DrawTexture', window, tex3, [], bpos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WaitUntil(t_start)

% Get this display up on the screen
Screen('Flip', window);  % Put up on the screen
Screen('Close',tex);
Screen('Close',tex2);
Screen('Close',tex3);   

if tbox == 1
    Answer = tbox;
elseif tbox == 2
    Answer = 4;
end
