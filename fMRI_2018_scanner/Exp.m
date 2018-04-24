%%% 13/9/16 - All scripts have 4 lines where 1,2,and 3 are the three
%%% different pitches. 4 is the constant fact check
%%% 1 = Confirmation pitch 
%%% 2 = Correction/Interference pitch
%%% 3 = Correction/No Interference pitch
%%% 4 = Constant fact check

%this program presents misinformation scripts for use in fMRI in Bristol
clear all;
global ptb3
KbName('UnifyKeyNames');
Screen('Preference', 'SkipSyncTests', 1);
%:::::::::::::::: open response box if present (crb=1)

crb=0; %set manual switch to tell program whether there is a response box

if crb
    handle =  CedrusResponseBox('Open', 'COM1');
    %Clear all queues, discard all pending data.
    CedrusResponseBox('ClearQueues', handle);
else
    handle = 0;
end

ptb3=-1;

% experiment files
datafile = 'results.dat';
scriptFn = 'scripts.txt';
scCond = xlsread('scCond.xlsx'); %this is currently set up for 78 scripts - edit for different numbers 
imcell = readimages;
subCond = xlsread('subject_condition.xlsx'); %reads in randomised subject number with associated column information for scCond - 'subject' will index this array

%parameters and constants
firstlofScript=3:6:15;   % points to first line of each script EDIT FOR MORE SCRIPTS IF REQUIRED
nScript = 3; % currently at 78
nlpScript = 4;   % yes still have 4 lines though a different set up
onsetsPerScript = 6; %7/1/18 kept at 6 for now so as not to complicate the present story
respPerScript = 2;
spaceorbutton = 'Space Bar';
beginmsg =  ['Press ' spaceorbutton ' to Begin Experiment'];
nextmsg =   'NEW PITCH';
endmsg =     'Experiment Over -- Thank You for Participating';
attentionmsg = 'Negative or Positive?'; % going to hardcode this into the scripts
allButtons = [1 2 3 4 5 6];  %allow for scanner signal to shut down if needed
scannerSignal = 6;

if crb
    beginmsg =  ['Get Ready to Begin Experiment'];
    breakmsg = ['Halfway break - Please do not move - The Experiment Will Resume Shortly'];
    secondRun = ['Get ready'];
else
    spaceorbutton = 'Space Bar';
    beginmsg =  ['Press ' spaceorbutton ' to Begin Experiment'];
    breakmsg = ['Halfway break - Please do not move - Press ' spaceorbutton ' to Resume Experiment'];
    secondRun = ['Get ready'];
end

%:::::::::::::::: read scripts and put them into presentable format

scriptinfo=textread(scriptFn,'%q');
script=cell(nScript,nlpScript); 
k=0;
for l1=firstlofScript  %first line of each script
    k=k+1;
    for j=1:nlpScript
        script{k,j}=scriptinfo{l1+j,1};
    end
end

%%% CHECKED ABOVE AND WORKS

%:::::::::::::::: set up structure to run experiment
cv = clock;
seed = fix(sum(cv(3:6))*100);
rand('state',seed);

onsetTimes = zeros(nScript,onsetsPerScript); 
responses = zeros(nScript,respPerScript);
kp = zeros(nScript,respPerScript);

% Develop script order 
scriptOrder = scCond(randperm(size(scCond,1)),:); %shuffles script and condition rows into random order
scriptID = scriptOrder(:,1); %can keep this but condition information will have to wait until after sub num entered

% KEEP?!
onsetTimesTot = zeros(nScript,onsetsPerScript);
responsesTot = zeros(nScript,respPerScript);
kpTot = zeros(nScript,respPerScript);

%::::::::::::::::: get subject number, and set up screen
getptb;
screenparms = prepexp;
tempSubject=getSubject(screenparms); % this is fine as it is just grabbing the subject number from what was entered on the first screen
subject=subCond(tempSubject,1); %now change subject number to the randomised order already made
scriptCond = scriptOrder(:,(subCond(tempSubject,2)+1)); %this says what column of script conditions to use based on the subject number (add 1 due to non-matching columns)
%this works

if ptb3
    expinfo.stimulussize = 50;
    expinfo.msgsize = 25;
else
    expinfo.stimulussize = (screenparms.rect(RectBottom) - screenparms.rect(RectTop))/8;
    expinfo.msgsize = 40;
end

expinfo.textrow = 20;
expinfo.x4box = screenparms.rect(RectRight)/4;
expinfo.x4q = screenparms.rect(RectRight)/4;
expinfo.y4box = screenparms.rect(RectBottom)/3;
expinfo.gap2q = 80; %vertical gap between comment and questions
% expinfo.y4q assigned after comment is printed
expinfo.wrapat = 35;

%timing information...
expinfo.lowintertrialinterval = 6;
expinfo.highintertrialinterval = 12;
expinfo.meanintertrialinterval = 9;
expinfo.getreadytime = .5;  % how long any of the warning messages will remain on-screen
expinfo.lowjitter = 4;
expinfo.highjitter = 8;
expinfo.meanjitter = 6; %8.1.18 increased to range between 4-8 seconds
expinfo.maxwait = 3; 
expinfo.picwait = 1.5; % EXTEND THIS TO ALLOW FOR BOTH PICTURES?
expinfo.TPW = .3; 

%%%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Screen('FillRect', screenparms.window, screenparms.black);
Screen('Flip',screenparms.window);

%wait for keypress to begin experiment proper
expinfo.scannerOnTime = waitfkey (screenparms, expinfo, ...
    beginmsg, handle, scannerSignal);
WaitSecs(2);

%%% RUN 1:::::::::::::::::::::::::::::::::::::::
for i=1:3;
    
    [onsetTimesTot(i,:), responsesTot(i,:), kpTot(i,:)] = presentStory(i, screenparms, ...
        expinfo, scriptID ,script, scriptCond, imcell, handle, subject);
    
end

%:::::::::::::::::: now record data
fid = fopen (datafile,'a');
for i=1:nScript
    fprintf (fid, '%3d %7d   %2d   %3d %3d   %3d     ', subject);
    fprintf (fid, ' %.0f', scriptID(i,1));
    fprintf (fid, ' %.0f', scriptCond(i,1));
    for j=1:onsetsPerScript
        fprintf (fid, ' %7.3f', onsetTimesTot(i,j));
    end
    fprintf(fid,'   ');
    for j=1:respPerScript
        fprintf (fid, ' %7.3f', kpTot(i,j));
    end
    fprintf(fid,'   ');
    for j=1:respPerScript
        fprintf (fid, ' %3d', responsesTot(i,j));
    end
    fprintf (fid,'\n');
end
fclose(fid);

%::::::::::::::: normal program termination
shutDown;

