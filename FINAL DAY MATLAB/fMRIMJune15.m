%%% fixation, bell at script start, fixation during script, exclamation
%%% mark to begin questions, fixation cross - get rid of writing  - FINISHED 8/6/15

%%% program for only right hand response - FINISHED 8/6/15

%%% 2 runs? ~22mins?

%%% black background white presentation - FINISHED 8/6/15

%%% scripts 23 and 24 have been renamed scripts 11 and 12, the
%%% corresponding question have been renamed p6 rather than p12 - FINISHED 8/6/15

%%% 30/04/15 All scripts show lines 1 x 4 5 6 7, where x is as follows:
%%% cond# condLabel x
%%%   1     CON     3  CASE 1
%%%   2     MI+R    2  CASE 2
%%% Scripts cut to length of 7 due to no MI condition
%%% 6Sentence 6 presented in every script - either functions as a
%%% retraction or as no retraction


%this program presents misinformation scripts for use in fMRI in Bristol
clear all;
global ptb3
%PsychJavaTrouble   %add path dynamically if needed...
KbName('UnifyKeyNames');  %suggested by Andreas Jarvstad 29/4/14 to
%make compatible with PTB > 3

%:::::::::::::::: open response box if present (crb=1)

crb=0; %set manual switch to tell program whether there is a response box - HAVE TO CHANGE THIS TO 1 MANUALLY FOR fMRI

if crb
    handle =  CedrusResponseBox('Open', 'COM1');
    %Clear all queues, discard all pending data.
    CedrusResponseBox('ClearQueues', handle);
else
    handle = 0;
end

ptb3=-1;

%::::::::::::::::: experimental parameters and constants
mySubRand = [22 6 3 16 11 7 17 14 8 5 21 19 15 1 23 2 4 18 24 13 9 20 10 12];
datafile = 'fMRIM2015.dat';
scriptFn = 'scriptfilenames.txt';
qFn = 'testfilenames.txt';
load('pairflip');  
firstlofScript = 3:10:213;
firstlofQs = 1:5:106;
nScript = length(firstlofScript);
nQs = 3;         % 3 inference
nlpScript = 7;
exclam = imread('exclamation.png');
questM = imread('question.png');


if crb
    spaceorbutton= 'Any Button';
    beginmsg =  ['Get Ready to Begin Experiment'];
    breakmsg = ['Halfway break - Please do not move - The Experiment Will Resume Shortly'];
    secondRun = ['Get ready'];
else
    spaceorbutton = 'Space Bar';
    beginmsg =  ['Press Space Bar to Begin Experiment'];
    breakmsg = ['Halfway break - Please do not move - Press ' spaceorbutton ' to Resume Experiment'];
    secondRun = ['Get ready'];
end

endmsg =     'Experiment Over -- Thank You for Participating';

allButtons = [1 2 3 4 5 6];  % allow for scanner signal to shut down if needed
scannerSignal = 6; 

% read in sentence file names and put them in a suitable format
scriptinfo=textread(scriptFn,'%q');
script=cell(nScript,nlpScript);
k=0;
for i=firstlofScript
    k=k+1;
    for j=1:nlpScript
        script{k,j}=scriptinfo{i+j,1};
    end
end
saudiofile=cell(nScript,nlpScript);
k=0;
for i=1:length(firstlofScript)
    k=k+1;
    for j=1:nlpScript
        saudiofile{k,j}=audioread(script{i,j});
    end
end

% read in question file names and put them in a suitable format
qinfo=textread(qFn,'%q');
questions=cell(nScript,nQs);
k=0;
for i=firstlofQs
    k=k+1;
    for j=1:nQs
        questions{k,j}=qinfo{i+j,1};
    end
end
qaudiofile=cell(nScript,nQs);
k=0;
for i=1:length(firstlofQs)
    k=k+1;
    for j=1:nQs
        qaudiofile{k,j}=audioread(questions{i,j});
    end
end

%:::::::::::::::: set up structure to run experiment

cv = clock;
seed = fix(sum(cv(3:6))*100);
rand('state',seed);

getptb;
screenparms = prepexp;
subjectPtr = getSubject(screenparms); % subjectPtr = entered subject number on start screen
subject=mySubRand(subjectPtr);  % subject = element of mySubRand indexed by subjectPtr
scriptOnsetTimes = zeros(nScript,nlpScript-1)';
scriptOffsetTimes = zeros(nScript,nlpScript-1)';
questionOnsetTimes = zeros(nScript,nQs)';
questionOffsetTimes = zeros(nScript,nQs)';
scaleOnsetTimes = zeros(nScript,nQs)';
scaleOffsetTimes = zeros(nScript,nQs)';
responses = zeros(nScript,nQs)';
scriptID = 1:nScript;
scriptOrder = sOrder % calls sOrder function to create a vector containing the script order
scriptCond = pairflips(subject,:);     % vector of length 24 indicating script condition

tinfo = struct('scriptID', num2cell(scriptID,1), ...
    'scriptOnsetTimes' , num2cell(scriptOnsetTimes,1), ...
    'scriptOffsetTimes' , num2cell(scriptOffsetTimes,1), ...
    'questionOnsetTimes', num2cell(questionOnsetTimes,1), ...
    'questionOffsetTimes', num2cell(questionOnsetTimes,1), ...
    'scriptCond', num2cell(scriptCond,1), ...
    'qid',num2cell(responses,1),...
    'scaleOnsetTimes',num2cell(scaleOnsetTimes,1), ...
    'scaleOffsetTimes',num2cell(scaleOnsetTimes,1), ...
    'responses', num2cell(responses,1));
tp=scriptOrder; % this is dictating the order of the scripts for each subject

%::::::::::::::::: get subject number, and set up screen
if ptb3
    expinfo.stimulussize = 50;
    expinfo.msgsize = 25;
else
    expinfo.stimulussize = (screenparms.rect(RectBottom) - screenparms.rect(RectTop))/8;
    expinfo.msgsize = 40;
end
expinfo.textrow = 20;
expinfo.nokey = 'SPACE';  %to advance script line by line
expinfo.yeskey = '/';
expinfo.x4box = screenparms.rect(RectRight)/4;
expinfo.x4q = screenparms.rect(RectRight)/4;
expinfo.y4box = screenparms.rect(RectBottom)/3;
expinfo.gap2q = 80; %vertical gap between comment and questions
% expinfo.y4q assigned after comment is printed
expinfo.wrapat = 80;
expinfo.intertrialinterval = 10; % changed from 10 to 15
expinfo.getreadytime = 1;  %agreed on 12/5/14
expinfo.mintestdelay = 15;
expinfo.maxtestdelay = 18;
expinfo.minencjitter = [1 1 2 2 2];
expinfo.maxencjitter = [3 3 4 5 6];
expinfo.minqjitter = 4;
expinfo.maxqjitter = 8;
expinfo.maxwait = 1.5;

% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Screen('FillRect', screenparms.window, screenparms.black);
Screen('Flip',screenparms.window);

%wait for keypress for experiment proper


expinfo.scannerOnTime = waitfkey (screenparms, expinfo, ...
    beginmsg, handle, scannerSignal); %scannerSignal <-- after debugging this is being used - no need to change CRB details here as only a button press is required
WaitSecs(2);


% PART 1
for i=1:11
    Screen('PutImage', screenparms.window, exclam);
    Screen('Flip', screenparms.window);
    WaitSecs(1);
    Screen('FillRect', screenparms.window, screenparms.black);
    Screen('Flip',screenparms.window);
    WaitSecs(expinfo.getreadytime);
    DrawFormattedText(screenparms.window, '+' , 'center', 'center');
    Screen('Flip', screenparms.window);
    
    % present script and get onset times
    [tinfo(tp(i)).scriptOnsetTimes(:), tinfo(tp(i)).scriptOffsetTimes(:)] = presentScript(screenparms, expinfo, tinfo(tp(i)), saudiofile, handle);
    
    % generate test delay and wait that long
    % z = (expinfo.maxtestdelay-expinfo.mintestdelay).*rand + expinfo.mintestdelay; 
    WaitSecs(3);
    
    Screen('PutImage', screenparms.window, questM);
    Screen('Flip', screenparms.window);
    WaitSecs(2);
    DrawFormattedText(screenparms.window, '+' , 'center', 'center');
    Screen('Flip', screenparms.window);
     
    % present test questions and get responses and onset times
    [tinfo(tp(i)).responses(:), tinfo(tp(i)).qid(:), tinfo(tp(i)).questionOnsetTimes(:),tinfo(tp(i)).questionOffsetTimes(:), tinfo(tp(i)).scaleOnsetTimes(:), tinfo(tp(i)).scaleOffsetTimes(:)] = ...
        presentQuestion(screenparms, expinfo, tinfo(tp(i)), qaudiofile, handle);
    
    % now get ready for next trial
    if i<11
    WaitSecs(expinfo.intertrialinterval);  
    end
    
    if i < nScript
        Screen('TextSize', screenparms.window , expinfo.msgsize);
        Screen('TextFont', screenparms.window, screenparms.sansSerifFont);
        %WaitSecs(expinfo.getreadytime);
        cls(screenparms);
    end
end


waitfexpinp(screenparms, expinfo, breakmsg, handle, scannerSignal)

expinfo.scannerOnTime = waitfkey (screenparms, expinfo, ...
    secondRun, handle, scannerSignal); %scannerSignal <-- after debugging this is being used - no need to change CRB details here as only a button press is required
WaitSecs(2);

% PART 2
for i=12:22
    Screen('PutImage', screenparms.window, exclam);
    Screen('Flip', screenparms.window);
    WaitSecs(1);
    Screen('FillRect', screenparms.window, screenparms.black);
    Screen('Flip',screenparms.window);
    WaitSecs(expinfo.getreadytime);
    DrawFormattedText(screenparms.window, '+' , 'center', 'center');
    Screen('Flip', screenparms.window);
    
    % present script and get onset times
    [tinfo(tp(i)).scriptOnsetTimes(:), tinfo(tp(i)).scriptOffsetTimes(:)] = presentScript(screenparms, expinfo, tinfo(tp(i)), saudiofile, handle);
    
    % generate test delay and wait that long
    z = (expinfo.maxtestdelay-expinfo.mintestdelay).*rand + expinfo.mintestdelay; 
    WaitSecs(z);
    
    Screen('PutImage', screenparms.window, questM);
    Screen('Flip', screenparms.window);
    WaitSecs(2);
    DrawFormattedText(screenparms.window, '+' , 'center', 'center');
    Screen('Flip', screenparms.window);
     
    % present test questions and get responses and onset times
    [tinfo(tp(i)).responses(:), tinfo(tp(i)).qid(:), tinfo(tp(i)).questionOnsetTimes(:),tinfo(tp(i)).questionOffsetTimes(:), tinfo(tp(i)).scaleOnsetTimes(:), tinfo(tp(i)).scaleOffsetTimes(:)] = ...
        presentQuestion(screenparms, expinfo, tinfo(tp(i)), qaudiofile, handle);
    
    % now get ready for next trial
    if i<22
    WaitSecs(expinfo.intertrialinterval);  
    end
    
    if i < nScript
        Screen('TextSize', screenparms.window , expinfo.msgsize);
        Screen('TextFont', screenparms.window, screenparms.sansSerifFont);
        WaitSecs(expinfo.getreadytime);
        cls(screenparms);
    end
end

% now record data
fid = fopen (datafile,'a');
for i=1:nScript
    fprintf (fid, '%3d %7d   %2d   %3d %3d   %3d     ', subject, seed, i, ...
        tinfo(tp(i)).scriptID, tinfo(tp(i)).scriptCond );
    for j=1:nlpScript-1 % changed to 1 from 3
        fprintf (fid, ' %7.3f', tinfo(tp(i)).scriptOnsetTimes(j));
    end
    fprintf(fid,'   ');
     for j=1:nlpScript-1 % changed to 1 from 3
        fprintf (fid, ' %7.3f', tinfo(tp(i)).scriptOffsetTimes(j));
    end
    fprintf(fid,'   ');
    for j=1:nQs
        fprintf (fid, ' %3d', tinfo(tp(i)).qid(j));
    end
    fprintf(fid,'   ');
    for j=1:nQs
        fprintf (fid, ' %7.3f', tinfo(tp(i)).questionOnsetTimes(j));
    end
    fprintf(fid,'   ');
      for j=1:nQs
        fprintf (fid, ' %7.3f', tinfo(tp(i)).questionOffsetTimes(j));
    end
    fprintf(fid,'   ');
    for j=1:nQs
        fprintf (fid, ' %3d', tinfo(tp(i)).responses(j));
    end
    fprintf (fid,'   ');
     for j=1:nQs
        fprintf (fid, ' %7.3f', tinfo(tp(i)).scaleOnsetTimes(j));
    end
    fprintf (fid,'   ');
      for j=1:nQs
        fprintf (fid, ' %7.3f', tinfo(tp(i)).scaleOffsetTimes(j));
    end
    fprintf (fid,'\n');
end
fclose(fid);


waitfkey (screenparms, expinfo, endmsg, 0, allButtons);

%::::::::::::::: normal program termination
shutDown;




