function err = ONSTest(subjnum,dirname)
% This is the test file with old, similar and new judgments.
% CS 4/7/08
%
% minor changes, designed for Objs Set C 
% JW 6/19/09
%
% will now find the lure bins and write it to the log file
% CS 7/27/09
%
% will also compute lure stats at the end
% JW 8/4/09

global Parm;

path('StarkLabPToolboxFuncs',path);  % Add subdir w/toolbox funcs to path

    
% Generate the stim lists
GenerateStimSets(subjnum);

% Setup variables we'll use for timing
duration = 2;
ISI = 0.5;
%duration = 0.1;
%ISI = 0.1;
trial_duration = duration + ISI;
if (nargin < 2)
    dirname = 'Set C';
end

if (dirname == 'Set C')
    normbin = dlmread('SetC bins.txt');
elseif (dirname == 'Set D')
    normbin = dlmread('SetD bins.txt');
else
    fprintf(1,'Error -- invalid directory name\n');
    return;
end

% Setup log file
fname = sprintf('s%d_log.txt',subjnum);
fid = fopen(fname,'a');  % Open log file in append mode

npercond = length(Parm.TargetList);
ntrials = npercond * 3;

fprintf(fid,'%s\nTest phase (group: %d)\nSubj: %d\n',datestr(now),Parm.Group,subjnum);
fprintf(fid,'Trialnum\tfilename\tcondition\tLureBin\tresponse\taccuracy\trt\n');

% Create random orders
%rand('seed',subjnum); Have replaced this line with new recommended syntax
rng(subjnum);% Use subject number as the random 'seed'
trial_order = mod(randperm(ntrials),3); % 0=old/target, 1=similar/lure, 2=new/foil
target_order = randperm(npercond);
foil_order = randperm(npercond);
lure_order = randperm(npercond);
target_index = 1;
foil_index = 1;
lure_index = 1;

% Setup screen in Psychtoolbox
screenNum=0;  % which screen to put things on
OrigScreenLevel = Screen('Preference','Verbosity',1);  % Set to less verbose output
window = Screen(screenNum,'OpenWindow');  % Open the screen
Screen('TextSize',window,36);
KbName('UnifyKeyNames');

% Pre-load the first image
if (trial_order(1) == 0)
    fname = sprintf('%s/%s',dirname,char(Parm.TargetList(target_order(target_index))));
    target_index = target_index+1;
elseif (trial_order(1) == 1)
    fname = sprintf('%s/%s',dirname,char(Parm.LureList(lure_order(lure_index))));
    lure_index = lure_index+1;
else
    fname = sprintf('%s/%s',dirname,char(Parm.FoilList(foil_order(foil_index))));
    foil_index = foil_index+1;
end
img = imread(fname);

% Wait for user to hit a key
Screen(window,'FillRect',WhiteIndex(window)); % clear to black
DrawFormattedText(window,'Press (v) for old, (b) for similar and (n) for new.\n\nPress spacebar when you are ready to begin.','center','center',BlackIndex(window));
Screen(window,'Flip');  % put offscreen buffer onto screen
KbWait;

% Zero all counters for trial types
TO = 0; TN = 0; TS = 0; LO = 0; LN = 0; LS = 0; FO = 0; FN = 0; FS = 0; NR = 0;
sumtarget = 0; sumlure = 0; sumfoil = 0;

% Zero all counters for lure bins
L1O = 0; L1S = 0; L1N = 0; L2O = 0; L2S = 0; L2N = 0; L3O = 0; L3S = 0; L3N = 0; L4O = 0; L4S = 0; L4N = 0; L5O = 0; L5S = 0; L5N = 0; LNR = 0;
sumL1 = 0; sumL2 = 0; sumL3 = 0; sumL4 = 0; sumL5 = 0;

% Trial loop
t0 = GetSecs();  % time when the first trial started
for trial=1:ntrials
    fprintf(fid,'%d\t%s\t%d\t',trial,fname,trial_order(trial));
    t_start = t0 + (trial - 1) * trial_duration;  % When trial should have started
    Screen(window,'FillRect',WhiteIndex(window)); % clear to black
    Screen(window,'PutImage',img);  % draw onto offscreen buffer
    Screen(window,'Flip');  % put offscreen buffer onto screen
    lurebin = 0;
    if (trial_order(trial) == 1) % on a lure - figure the bin
        stimnum = sscanf(fname(7:9),'%3d');
        lurebin = normbin(stimnum,2);
    end
    fprintf(fid,'%d\t',lurebin); % write bin to logfile
    if (trial ~= ntrials) % not on last trial, load the next while the current is on screen
        if (trial_order(trial+1) == 0)
            fname = sprintf('%s/%s',dirname,char(Parm.TargetList(target_order(target_index))));
            target_index = target_index+1;
        elseif (trial_order(trial+1) == 1)
            fname = sprintf('%s/%s',dirname,char(Parm.LureList(lure_order(lure_index))));
            lure_index = lure_index+1;
        else
            fname = sprintf('%s/%s',dirname,char(Parm.FoilList(foil_order(foil_index))));
            foil_index = foil_index+1;
        end
        img = imread(fname);
    end

    Screen(window,'FillRect',WhiteIndex(window));  % Clear OSB to white in prep for ISI

    [keycode RT] = KbWaitUntil(t_start,duration);  % Wait until keypress or timeout
    if keycode
        keyname = KbName(keycode);
    else
        keyname = 'NR';
    end
    if (strcmp(keyname,'v'))  % Designation as old
        resp = 1;
    elseif (strcmp(keyname,'n')) % Designation as new
        resp = 2;
    elseif (strcmp(keyname, 'b')) % Designation as similar
        resp = 3;
    else
        resp = 0; % no response
    end

% Type is defined as TO, TN, TS, LO, LN, LS, FO, FN, FS
    %Accuracy
    if trial_order(trial) == 0 % old target
        sumtarget = sumtarget + 1;
        if resp == 1
            acc = 1; TO = TO + 1;
        elseif resp == 2
            acc = 0; TN = TN + 1;
        elseif resp == 3
            acc = 0; TS = TS + 1; 
        else
            acc = 0; NR = NR + 1;
        end
    elseif trial_order(trial) == 1 % similar lure
        sumlure = sumlure + 1;
        if resp == 1
            acc = 0; LO = LO + 1;
        elseif resp == 2
            acc = 0; LN = LN + 1;
        elseif resp == 3
            acc = 1; LS = LS + 1;
        else
            acc = 0; NR = NR + 1;
        end
    elseif trial_order(trial) == 2 % new foil
        sumfoil = sumfoil + 1;
        if resp == 1
            acc = 0; FO = FO + 1;
        elseif resp == 2
            acc = 1; FN = FN + 1;
        elseif resp == 3
            acc = 0; FS = FS + 1;
        else
            acc = 0; NR = NR + 1;
        end
    end
    
    % setting up stats for lurebins
    if lurebin == 1
        sumL1 = sumL1 + 1;
        if resp == 1
            L1O = L1O + 1;
        elseif resp == 2
            L1N = L1N + 1;
        elseif resp == 3
            L1S = L1S + 1;
        else
            LNR = LNR + 1;
        end
    elseif lurebin == 2
        sumL2 = sumL2 + 1;
        if resp == 1
            L2O = L2O + 1;
        elseif resp == 2
            L2N = L2N + 1;
        elseif resp == 3
            L2S = L2S + 1;
        else
            LNR = LNR + 1;
        end
    elseif lurebin == 3
        sumL3 = sumL3 + 1;
        if resp == 1
            L3O = L3O + 1;
        elseif resp == 2
            L3N = L3N + 1;
        elseif resp == 3
            L3S = L3S + 1;
        else
            LNR = LNR + 1;
        end
    elseif lurebin == 4
        sumL4 = sumL4 + 1;
        if resp == 1
            L4O = L4O + 1;
        elseif resp == 2
            L4N = L4N + 1;
        elseif resp == 3
            L4S = L4S + 1;
        else
            LNR = LNR + 1;
        end
    elseif lurebin == 5
        sumL5 = sumL5 + 1;
        if resp == 1
            L5O = L5O + 1;
        elseif resp == 2
            L5N = L5N + 1;
        elseif resp == 3
            L5S = L5S + 1;
        else
            LNR = LNR + 1;
        end
    else
    end
    
    fprintf(fid,'%d\t%d\t%.1f\n',resp,acc,RT*1000);
    %    if (keyname == escape) break; end % ESC hit
    if (strcmp(keyname,'ESCAPE')) break; end % ESC hit
    if (RT) WaitUntil(t_start + duration); end % If response made, wait until end of trial.  (on timeout, already there)
    Screen(window,'Flip');  % Clear screen (from already whiteened OSB)
    WaitUntil (t_start + trial_duration); 
end

fprintf(fid,'\nSession Statistics\n');
fprintf(fid,'TO\tTN\tTS\tLO\tLN\tLS\tFO\tFN\tFS\tNR\n');
fprintf(fid,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n',TO, TN, TS, LO, LN, LS, FO, FN, FS, NR);
TO_rate = TO./sumtarget; TN_rate = TN./sumtarget; TS_rate = TS./sumtarget; LO_rate = LO./sumlure; 
LN_rate = LN./sumlure; LS_rate = LS./sumlure; FN_rate = FN./sumfoil; FS_rate = FS./sumfoil; 
FO_rate = FO./sumfoil; NR_rate = NR./(sumfoil+sumlure+sumtarget); 

fprintf(fid,'\nTotal target trials\t%d\n', sumtarget);
fprintf(fid,'Rate(old | target)\t%.4f\n', TO_rate);
fprintf(fid,'Rate(new | target)\t%.4f\n', TN_rate);
fprintf(fid,'Rate(similar | target)\t%.4f\n', TS_rate);

fprintf(fid,'\nTotal lure trials\t%d\n', sumlure);
fprintf(fid,'Rate(old | lure)\t%.4f\n', LO_rate);
fprintf(fid,'Rate(new | lure)\t%.4f\n', LN_rate);
fprintf(fid,'Rate(similar | lure)\t%.4f\n', LS_rate);

fprintf(fid,'\nTotal foil trials\t%d\n', sumfoil);
fprintf(fid,'Rate(old | foil)\t%.4f\n', FO_rate);
fprintf(fid,'Rate(new | foil)\t%.4f\n', FN_rate);
fprintf(fid,'Rate(similar | foil)\t%.4f\n', FS_rate);

fprintf(fid,'\nLureBin Statistics\n');
fprintf(fid,'L1O\tL1S\tL1N\tL2O\tL2S\tL2N\tL3O\tL3S\tL3N\tL4O\tL4S\tL4N\tL5O\tL5S\tL5N\tLNR\n');
fprintf(fid,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n', L1O, L1S, L1N, L2O, L2S, L2N, L3O, L3S, L3N, L4O, L4S, L4N, L5O, L5S, L5N, LNR);

L1O_rate = L1O./sumL1; L1S_rate = L1S./sumL1; L1N_rate = L1N./sumL1;
L2O_rate = L2O./sumL2; L2S_rate = L2S./sumL2; L2N_rate = L2N./sumL2;
L3O_rate = L3O./sumL3; L3S_rate = L3S./sumL3; L3N_rate = L3N./sumL3;
L4O_rate = L4O./sumL4; L4S_rate = L4S./sumL4; L4N_rate = L4N./sumL4;
L5O_rate = L5O./sumL5; L5S_rate = L5S./sumL5; L5N_rate = L5N./sumL5;

fprintf(fid,'\nTotal LureBin one trials\t%d\n', sumL1);
fprintf(fid,'Rate(old | lure1)\t%.4f\n', L1O_rate);
fprintf(fid,'Rate(new | lure1)\t%.4f\n', L1N_rate);
fprintf(fid,'Rate(similar | lure1)\t%.4f\n', L1S_rate);

fprintf(fid,'\nTotal LureBin two trials\t%d\n', sumL2);
fprintf(fid,'Rate(old | lure2)\t%.4f\n', L2O_rate);
fprintf(fid,'Rate(new | lure2)\t%.4f\n', L2N_rate);
fprintf(fid,'Rate(similar | lure2)\t%.4f\n', L2S_rate);

fprintf(fid,'\nTotal LureBin three trials\t%d\n', sumL3);
fprintf(fid,'Rate(old | lure3)\t%.4f\n', L3O_rate);
fprintf(fid,'Rate(new | lure3)\t%.4f\n', L3N_rate);
fprintf(fid,'Rate(similar | lure3)\t%.4f\n', L3S_rate);

fprintf(fid,'\nTotal LureBin four trials\t%d\n', sumL4);
fprintf(fid,'Rate(old | lure4)\t%.4f\n', L4O_rate);
fprintf(fid,'Rate(new | lure4)\t%.4f\n', L4N_rate);
fprintf(fid,'Rate(similar | lure4)\t%.4f\n', L4S_rate);

fprintf(fid,'\nTotal LureBin five trials\t%d\n', sumL5);
fprintf(fid,'Rate(old | lure5)\t%.4f\n', L5O_rate);
fprintf(fid,'Rate(new | lure5)\t%.4f\n', L5N_rate);
fprintf(fid,'Rate(similar | lure5)\t%.4f\n', L5S_rate);

fclose(fid);
Screen('CloseAll');
Screen('Preference','Verbosity',OrigScreenLevel);