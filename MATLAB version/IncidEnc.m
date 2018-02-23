function err = IncidEnc(subjnum,dirname)
% Study phase - presents a basic study task
% GenerateStimSets is run to setup the stimuli
%
% last edited by JW 6/19/09
% minor changes, designed for Objs Set C

global Parm;

path('StarkLabPToolboxFuncs',path);  % Add subdir w/toolbox funcs to path


% Generate the stim lists
GenerateStimSets(subjnum);

% Setup variables we'll use for timing
duration = 2.0;
ISI = 0.5;
%duration = 0.1;
%ISI = 0.1;
trial_duration = duration + ISI;
if (nargin < 2)
    dirname = 'Set C';
end

% Setup log file
fname = sprintf('s%d_log.txt',subjnum);
fid = fopen(fname,'a');  % Open log file in append mode

ntrials = length(Parm.StudyList);

fprintf(fid,'%s\nStudy phase (group: %d)\nSubj: %d\n',datestr(now),Parm.Group,subjnum);
fprintf(fid,'Trialnum\tfilename\tresponse\trt\n');

% Create random orders
rand('seed',subjnum);  % Use subject number as the random 'seed'
trial_order = randperm(ntrials); 

% Setup screen in Psychtoolbox
screenNum=0;  % which screen to put things on
OrigScreenLevel = Screen('Preference','Verbosity',1);  % Set to less verbose output
window = Screen(screenNum,'OpenWindow');  % Open the screen
Screen('TextSize',window,36);
KbName('UnifyKeyNames');

% Pre-load the first image
fname = sprintf('%s/%s',dirname,char(Parm.StudyList(trial_order(1))));
img = imread(fname);

% Wait for user to hit a key
Screen(window,'FillRect',WhiteIndex(window)); % clear to black
DrawFormattedText(window,'Press (v) for indoor and (n) for outdoor items.\n\nPress spacebar when you are ready to begin.','center','center',BlackIndex(window));
Screen(window,'Flip');  % put offscreen buffer onto screen
KbWait;


% Trial loop
t0 = GetSecs();  % time when the first trial started
for trial=1:ntrials
    fprintf(fid,'%d\t%s\t',trial,fname);
    t_start = t0 + (trial - 1) * trial_duration;  % When trial should have started
    Screen(window,'FillRect',WhiteIndex(window)); % clear to black
    Screen(window,'PutImage',img);  % draw onto offscreen buffer
    Screen(window,'Flip');  % put offscreen buffer onto screen
    if (trial ~= ntrials) % not on last trial, load the next while the current is on screen
        fname = sprintf('%s/%s',dirname,char(Parm.StudyList(trial_order(trial+1))));
        img = imread(fname);
    end

    Screen(window,'FillRect',WhiteIndex(window));  % Clear OSB to white in prep for ISI
    
    [keycode RT] = KbWaitUntil(t_start,duration);  % Wait until keypress or timeout
    if keycode
        keyname = KbName(keycode);
    else
        keyname = 'NR';
    end
    fprintf(fid,'%d\t%.1f\n',keycode,RT*1000);
%    if (keycode == 41) break; end % ESC hit
    if (strcmp(keyname,'ESCAPE')) break; end % ESC hit
    
    if (RT) WaitUntil(t_start + duration); end % If response made, wait until end of trial.  (on timeout, already there)
    
    Screen(window,'Flip');  % Clear screen (from already whiteened OSB)
    
    WaitUntil (t_start + trial_duration);
end

fclose(fid);
Screen('CloseAll');
Screen('Preference','Verbosity',OrigScreenLevel);


