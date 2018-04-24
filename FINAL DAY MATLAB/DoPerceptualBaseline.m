function [resp RT correct] = DoPerceptualBaseline(window, start_time, stim_dur, ITI)
% This function will put a fixation up on the screen and run one trial for
% either study or test (and either test phase).

% Declare the persistent variables.  These will remain across calls to the
% function and let us adjust the alpha of the boxes to be tailored to the
% subject.
persistent talpha
persistent falpha
persistent history
if isempty(talpha) % Set original values
    talpha = 0.3;
    falpha = 0.2;
end

Screen(window,'FillRect',BlackIndex(window)); % clear to black

[XWinsize YWinsize] = Screen('WindowSize',window); % Get size of window

% Create basic noise background
bkgnoise = (rand(YWinsize,XWinsize) > 0.5) * 128;
tex=Screen('MakeTexture', window, bkgnoise);
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

% Get this display up on the screen
Screen('Flip', window);  % Put up on the screen
Screen('Close',tex);
Screen('Close',tex2);
Screen('Close',tex3);

Screen(window,'FillRect',WhiteIndex(window));  % Clear OSB to white in prep for ISI

[resp RT] = GatherResponse(stim_dur); % Get Subject's response, waiting up to 'duration'
if (resp == -1)  % User hit ESC - bail
    correct = 0;
    resp = 0;
    RT = 0;
    return;
end

if (RT)
    WaitUntil(start_time + stim_dur); % Response was made, keep the stim up until the end
end

Screen(window,'Flip');  % Clear screen (from already cleared OSB)

% Take care of updating the history on how well person is doing here
if (resp == tbox) 
    correct = 1;
else
    correct = 0;
end
if isempty(history)  % First time called, just add this into the history
    history = correct;
elseif length(history) < 10  % still early in the calling - just append
    history(length(history) + 1) = correct;
else % Have >=10 in here, score and do a sliding window
    history(1:9) = history(2:10);
    history(10) = correct;
    if (sum(history) > 7) % 80% correct or better
        talpha = talpha * 0.9;
    elseif (sum(history) < 5)
        talpha = talpha * 1.1;
    end
    if talpha <= falpha
        talpha = falpha + 0.02;
    end
end
%fprintf ('%d  %d  %d  %.2f  %.2f\n',correct,length(history),sum(history)>7,talpha,falpha);

% Wait the ITI
WaitUntil (start_time + stim_dur + ITI);
