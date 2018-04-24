function ContInciScannerLongResp(subjnum,dirname)
% 28/02/18 WJC - ContTest.m adjusted to be compatible with the CRIC scanner
%               Cedrus Box. Whether these changes are functional is not yet known
% 06/04/18 WJC - Has been tested with the scanner and is functional, although small changes
%   have been made which need to be retested

path('StarkLabPToolboxFuncs',path);  % Add subdir w/toolbox funcs to path

    
% Generate the stim lists
Parm = GenerateStimSets(subjnum);

% Setup variables we'll use for timing
duration = 2;
ISI = 1;
Blank = 0.2;
trial_duration = duration + ISI + Blank;
if (nargin < 2)
    dirname = 'Set C';
end

if strcmp(dirname, 'Set C')
    normbin = dlmread('SetC bins.txt');
elseif strcmp(dirname, 'Set D')
    normbin = dlmread('SetD bins.txt');
else
    fprintf(1,'Error -- invalid directory name\n');
    return;
end
% For baseline function
% Set original values
talpha = 0.3;
falpha = 0.2;


% Setup log file
fname = sprintf('Intentional%d_log.txt',subjnum);
if exist(fname, 'file')
    fprintf('The log file already exists, either delete this file or choose a different subject number');
    return
else
    fid = fopen(fname,'a');  % Open log file in append mode
end

%Generate Order file
trial_order = NewCreateOrder(subjnum);


npercond = length(Parm.TargetList);
ntrials = npercond * 3;
% if length(trial_order) ~= ntrials
%     fprintf(1,'The Trial Length from the Order file differs from that set in Main, %d compared to %d', length(trial_order), ntrials);
%     return;
% end

fprintf(fid,'%s\nTest phase (group: %d)\nSubj: %d\n',datestr(now),Parm.Group,subjnum);
fprintf(fid,'Trialnum\tfilename\tcondition\tLureBin\tresponse\taccuracy\trt\n');

% Setup Cedrus Box
WaitSecs(1.02) ;
handle =  CedrusResponseBox('Open', 'COM1');
CedrusResponseBox('FlushEvents', handle)
% evt = CedrusResponseBox('GetButtons', handle);

% Setup screen in Psychtoolbox
screenNum=0;  % which screen to put things on
OrigScreenLevel = Screen('Preference','Verbosity',1);  % Set to less verbose output
[window, rect] = Screen(screenNum,'OpenWindow');  % Open the screen
Screen('TextSize',window,26);
KbName('UnifyKeyNames');
[xCenter, yCenter] = RectCenter(rect);
fixCrossDimPix = 40;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

if trial_order(1,1) < 101
    fname = sprintf('%s/%sa.jpg',dirname,char(Parm.TargetList(trial_order(1,1))));
elseif trial_order(1,1) < 401
    fname = sprintf('%s/%sa.jpg',dirname,char(Parm.LureList(trial_order(1,1)-200)));
else
    fname = sprintf('%s/%sa.jpg',dirname,char(Parm.FoilList(trial_order(1,1)-400)));
end
img = imread(fname);

% Wait for user to hit a key
Screen(window,'FillRect',WhiteIndex(window)); % clear to black
DrawFormattedText(window,'Press the Left Button if you would find the object outside,\n\n the Right Button if you would find it inside.\n\n\n\nPress the Left Button when you are ready to begin.','center','center',BlackIndex(window));
Screen(window,'Flip');  % put offscreen buffer onto screen
Screen(window,'FillRect',WhiteIndex(window)); % clear to blanck
DrawFormattedText(window,'The task will begin shortly...','center','center',BlackIndex(window));

waitforbuttonpress = 0;
while ~waitforbuttonpress
    evt = CedrusResponseBox('GetButtons', handle);
    if ~isempty(evt) && ((evt.button == 2))
        waitforbuttonpress = 1;
    end
    WaitSecs(0.05);
end
Screen(window,'Flip');
CedrusResponseBox('ClearQueues', handle);
CedrusResponseBox('FlushEvents', handle); %<--to flush the queue
       
waitfortrigger = 0;
while ~waitfortrigger 
  evt = CedrusResponseBox('GetButtons', handle);  %'WaitButtonPress' might work better?

  if ~isempty(evt) && ((evt.button == 6))             
    buttons = 1;
    while any(buttons(1,:))
        buttons = CedrusResponseBox('FlushEvents', handle);
    end
    waitfortrigger = 1;
    ScannerStartTime = GetSecs;
  end
end

% Zero all counters for trial types
TO = 0; TN = 0; LO = 0; LN = 0; FO = 0; FN = 0; NR = 0; VB = 0;
sumtarget = 0; sumlure = 0; sumfoil = 0;

% Zero all counters for lure bins
L1O = 0; L1NR = 0; L1N = 0; L2O = 0; L2NR = 0; L2N = 0; L3O = 0; L3NR = 0; L3N = 0; L4O = 0; L4NR = 0; L4N = 0; L5O = 0; L5NR = 0; L5N = 0;
sumL1 = 0; sumL2 = 0; sumL3 = 0; sumL4 = 0; sumL5 = 0;

% Trial loop
foil = 1;
baseline = 0;
trialnorm = 1;
t0 = GetSecs();  % time when the first trial started
fprintf(fid,'Scanner Trigger Time = %.3f\tTest Start Time = %.3f\n', ScannerStartTime, t0);
for trial=1:ntrials
    
    t_start = t0 + (trial - 1) * trial_duration;  % When trial should have started
    
    if trialnorm == 1
        fprintf(fid,'%d\t%s\t%d\t',trial,fname,trial_order(trial,1));
        Screen(window,'FillRect',WhiteIndex(window)); % clear to black
        Screen(window,'PutImage',img);  % draw onto offscreen buffer
        Screen(window,'Flip');  % put offscreen buffer onto screen
        lurebin = 0;
        if trial_order(trial,1) > 300 && trial_order(trial,1) < 401 % showing of 2nd part of lure pair - figure the bin
            stimnum = sscanf(fname(7:9),'%3d');
            lurebin = normbin(stimnum,2);
        end
        fprintf(fid,'%d\t',lurebin); % write bin to logfile
    else
        fprintf(fid,'Baseline\t');
        [BaselineAns] = DoPerceptualBaselineScanner(window, t_start, talpha, falpha);
    end
    if(trial ~= ntrials) % not on last trial, load the next while the current is on screen
        if trial_order(trial+1,1) < 101
            fname = sprintf('%s/%sa.jpg',dirname,char(Parm.TargetList(trial_order(trial+1,1))));
        elseif trial_order(trial+1,1) < 201
            fname = sprintf('%s/%sa.jpg',dirname,char(Parm.TargetList(trial_order(trial+1,1)-100)));
        elseif trial_order(trial+1,1) < 301
            fname = sprintf('%s/%sa.jpg',dirname,char(Parm.LureList(trial_order(trial+1,1)-200)));
        elseif trial_order(trial+1,1) < 401
            fname = sprintf('%s/%sb.jpg',dirname,char(Parm.LureList(trial_order(trial+1,1)-300)));
        else
            if foil == 1
                fname = sprintf('%s/%sa.jpg',dirname,char(Parm.FoilList(trial_order(trial+1,1)-400)));
                foil = 0;
            else
                fname = sprintf('%s/%sa.jpg',dirname,char(Parm.FoilList(trial_order(trial+1,1)-400)));
                baseline = 1;
                foil = 1;
            end
        end
        img = imread(fname);
    end

    Screen(window,'FillRect',WhiteIndex(window));  % Clear OSB to white in prep for ISI
    Screen('DrawLines', window, allCoords, 4, BlackIndex(window), [xCenter yCenter], 1);

    WaitUntil(t_start + 0.1);
    %Included this 0.1 second wait as human reaction times to visual
    %stimuli tend to be ~0.17s, hence any response in times less than 0.1s
    %from trail start should be ignored.
    box = CedrusResponseBox('GetBaseTimer', handle);
    CedrusResponseBox('FlushEvents', handle)
%     evt = CedrusResponseBox('GetButtons', handle);
    WaitUntil(t_start + duration);
    Screen(window,'Flip');
    Screen(window,'FillRect',WhiteIndex(window));
    WaitUntil(t_start + duration + ISI);
    Screen(window,'Flip');
    responsefound = 0;
    tries = 0;
    while ~responsefound && tries < 6
        evt = CedrusResponseBox('GetButtons', handle);
        [~,~,keyname] = KbCheck();
        if keyname(27) == 1
            CedrusResponseBox('Close', handle);
            fclose(fid);
            Screen('CloseAll');
            return;
        end
        if ~isempty(evt) && (evt.action == 1)
                responsefound = 1;
        end
        tries = tries + 1;
    end
    
    if ~isempty(evt) && (evt.action == 1)
            resp = evt.button - 1;
            if resp > 4
                resp = 0;
            end
            RT = evt.rawtime - box.basetimer + 0.1;
    else
        resp = 0;
        RT = 0;
%         RT = int32(0);
    end
    
    
    if trialnorm == 1
    % Type is defined as TO, TN, TS, LO, LN, LS, FO, FN, FS
        %Accuracy
        if trial_order(trial,1) > 100 && trial_order(trial,1) < 201 % old target
            sumtarget = sumtarget + 1;
            if resp == 1
                acc = 1; TO = TO + 1;
            elseif resp == 2 || resp == 3
                acc = 0; VB = VB + 1;
            elseif resp == 4
                acc = 0; TN = TN + 1; 
            else
                acc = 0; NR = NR + 1;
            end
        elseif trial_order(trial,1) > 300 && trial_order(trial,1) <401 % similar lure
            sumlure = sumlure + 1;
            if resp == 1
                acc = 0; LO = LO + 1;
            elseif resp == 2 || resp == 3
                acc = 0; VB = VB + 1;
            elseif resp == 4
                acc = 1; LN = LN + 1;
            else
                acc = 0; NR = NR + 1;
            end
        else % new foil
            sumfoil = sumfoil + 1;
            if resp == 1
                acc = 0; FO = FO + 1;
            elseif resp == 2 || resp == 3
                acc = 0; VB = VB + 1;
            elseif resp == 4
                acc = 1; FN = FN + 1;
            else
                acc = 0; NR = NR + 1;
            end
        end

        % setting up stats for lurebins
        if lurebin == 1
            sumL1 = sumL1 + 1;
            if resp == 1
                L1O = L1O + 1;
            elseif resp == 4
                L1N = L1N + 1;
            else
                L1NR = L1NR + 1;
            end
        elseif lurebin == 2
            sumL2 = sumL2 + 1;
            if resp == 1
                L2O = L2O + 1;
            elseif resp == 2
                L2N = L2N + 1;
            else
                L2NR = L2NR + 1;
            end
        elseif lurebin == 3
            sumL3 = sumL3 + 1;
            if resp == 1
                L3O = L3O + 1;
            elseif resp == 4
                L3N = L3N + 1;
            else
                L3NR = L3NR + 1;
            end
        elseif lurebin == 4
            sumL4 = sumL4 + 1;
            if resp == 1
                L4O = L4O + 1;
            elseif resp == 4
                L4N = L4N + 1;
            else
                L4NR = L4NR + 1;
            end
        elseif lurebin == 5
            sumL5 = sumL5 + 1;
            if resp == 1
                L5O = L5O + 1;
            elseif resp == 4
                L5N = L5N + 1;
            else
                L5NR = L5NR + 1;
            end
        else
        end
        fprintf(fid,'%d\t%d\t%4.0f\n',resp,acc,RT*1000);
    else
        if BaselineAns == resp
            acc = 1;
        else
            acc = 0;
        end

        fprintf(fid,'%.3f\t%.3f\t%d\t%4.0f\n', talpha, falpha, acc, RT*1000);

        if isempty(history)  % First time called, just add this into the history
            history = acc;
        elseif length(history) < 10  % still early in the calling - just append
            history(length(history) + 1) = acc;
        else % Have >=10 in here, score and do a sliding window
            history(1:9) = history(2:10);
            history(10) = acc;
            if (sum(history) > 7) % 80% correct or better
                talpha = talpha * 0.9;
            elseif (sum(history) < 5)
                talpha = talpha * 1.1;
            end
            if talpha <= falpha
                talpha = falpha + 0.02;
            end
        end
       
        baseline = 0;
    end
    if baseline == 0
        WaitUntil (t_start + trial_duration); 
        trialnorm = 1;
    else 
        trialnorm = 0;
    end
end

CedrusResponseBox('Close', handle);

fprintf(fid,'\nSession Statistics\n');
fprintf(fid,'TO\tTN\tLO\tLN\tFO\tFN\tNR\tVB\n');
fprintf(fid,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n',TO, TN, LO, LN, FO, FN, NR, VB);
TO_rate = TO./sumtarget; TN_rate = TN./sumtarget; LO_rate = LO./sumlure; 
LN_rate = LN./sumlure; FN_rate = FN./sumfoil; 
FO_rate = FO./sumfoil; NR_rate = NR./(sumfoil+sumlure+sumtarget); 
VB_rate = VB./(sumfoil+sumlure+sumtarget);

fprintf(fid,'\nTotal target trials\t%d\n', sumtarget);
fprintf(fid,'Rate(old | target)\t%.4f\n', TO_rate);
fprintf(fid,'Rate(new | target)\t%.4f\n', TN_rate);

fprintf(fid,'\nTotal lure trials\t%d\n', sumlure);
fprintf(fid,'Rate(old | lure)\t%.4f\n', LO_rate);
fprintf(fid,'Rate(new | lure)\t%.4f\n', LN_rate);

fprintf(fid,'\nTotal foil trials\t%d\n', sumfoil);
fprintf(fid,'Rate(old | foil)\t%.4f\n', FO_rate);
fprintf(fid,'Rate(new | foil)\t%.4f\n', FN_rate);

fprintf(fid,'\nNo Response Rate\t%.4f\n', NR_rate);
fprintf(fid,'Void Button Press Rate\t%.4f\n', VB_rate);

fprintf(fid,'\nLureBin Statistics\n');
fprintf(fid,'L1O\tL1N\tL1NR\tL2O\tL2N\tL2NR\tL3O\tL3N\tL3NR\tL4O\tL4N\tL4NR\tL5O\tL5N\t5LNR\n');
fprintf(fid,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n', L1O, L1N, L1NR, L2O, L2N, L2NR, L3O, L3N, L3NR, L4O, L4N, L4NR, L5O, L5N, L5NR);

L1O_rate = L1O./sumL1; L1NR_rate = L1NR./sumL1; L1N_rate = L1N./sumL1;
L2O_rate = L2O./sumL2; L2NR_rate = L2NR./sumL2; L2N_rate = L2N./sumL2;
L3O_rate = L3O./sumL3; L3NR_rate = L3NR./sumL3; L3N_rate = L3N./sumL3;
L4O_rate = L4O./sumL4; L4NR_rate = L4NR./sumL4; L4N_rate = L4N./sumL4;
L5O_rate = L5O./sumL5; L5NR_rate = L5NR./sumL5; L5N_rate = L5N./sumL5;

fprintf(fid,'\nTotal LureBin one trials\t%d\n', sumL1);
fprintf(fid,'Rate(old | lure1)\t%.4f\n', L1O_rate);
fprintf(fid,'Rate(new | lure1)\t%.4f\n', L1N_rate);
fprintf(fid,'Rate(NR | lure1)\t%.4f\n', L1NR_rate);

fprintf(fid,'\nTotal LureBin two trials\t%d\n', sumL2);
fprintf(fid,'Rate(old | lure2)\t%.4f\n', L2O_rate);
fprintf(fid,'Rate(new | lure2)\t%.4f\n', L2N_rate);
fprintf(fid,'Rate(NR | lure2)\t%.4f\n', L2NR_rate);

fprintf(fid,'\nTotal LureBin three trials\t%d\n', sumL3);
fprintf(fid,'Rate(old | lure3)\t%.4f\n', L3O_rate);
fprintf(fid,'Rate(new | lure3)\t%.4f\n', L3N_rate);
fprintf(fid,'Rate(NR | lure3)\t%.4f\n', L3NR_rate);

fprintf(fid,'\nTotal LureBin four trials\t%d\n', sumL4);
fprintf(fid,'Rate(old | lure4)\t%.4f\n', L4O_rate);
fprintf(fid,'Rate(new | lure4)\t%.4f\n', L4N_rate);
fprintf(fid,'Rate(NR | lure4)\t%.4f\n', L4NR_rate);

fprintf(fid,'\nTotal LureBin five trials\t%d\n', sumL5);
fprintf(fid,'Rate(old | lure5)\t%.4f\n', L5O_rate);
fprintf(fid,'Rate(new | lure5)\t%.4f\n', L5N_rate);
fprintf(fid,'Rate(NR | lure5)\t%.4f\n', L5NR_rate);

fclose(fid);
Screen('CloseAll');
Screen('Preference','Verbosity',OrigScreenLevel);