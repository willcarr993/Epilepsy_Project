% This program forms part of the Working Memory Capacity Battery, 
% written by Stephan Lewandowsky, Klaus Oberauer, Lee-Xieng Yang, and Ullrich Ecker. 
% The WMCBattery is available online at the website of the Cognitive Science
% Laboratories of the University of Western Australia's School of Psychology:
% http://www.cogsciwa.com ("Software" button on main menu).
% Conditions of Use: Using the WMCBattery is free of charge but the authors 
% request that the associated paper be cited (add details later) 
% when publications arise out of data collection with the WMCBattery. 
% The authors do not guarantee the WMCBattery's functionality. 
% This task requires Matlab version 7.5 (2007b) or higher and the 
% Psychophysics Toolbox version 2.54 or 3.0.8. 

function screenparms = prepexp
global ptb3

warning off MATLAB:DeprecatedLogicalAPI

% Open Psychtoolbox window

if ptb3;
    AssertOpenGL;
    % Screen is able to do a lot of configuration and performance checks on
    % open, and will print out a fair amount of detailed information when
    % it does.  These commands supress that checking behavior and just let
    % the demo go straight into action.  See ScreenTest for an example of
    % how to do detailed checking.
    Screen('Preference', 'VisualDebugLevel', 3);
    Screen('Preference', 'SuppressAllWarnings', 1);
    screenNumber=max(Screen('Screens'));
    if screenNumber > 1
        [screenparms.window, screenparms.rect] = Screen('OpenWindow', screenNumber, 0, [], 32,2);
    else
        [screenparms.window, screenparms.rect] = Screen('OpenWindow', 0);
        
    end
    ListenChar(2);                         %prevent keystrokes being passed through to MatLab
    Screen('Preference', 'Verbosity', 0); % Suppress warnings from PTB3
else
    screenparms.window = Screen(0,'OpenWindow');
    screenparms.rect   = Screen(screenparms.window,'Rect');
end;


ShowCursor(0);	% arrow cursor
HideCursor;
screenparms.white=WhiteIndex(screenparms.window);
screenparms.black=BlackIndex(screenparms.window);
screenparms.grey=floor((screenparms.white+screenparms.black)/2);
screenparms.red=[255 0 0];
screenparms.blue=[0 0 255];
screenparms.green=[0 255 0];
screenparms.yellow=[255 180 0];
screenparms.violet=[255 0 128];
screenparms.turquoise=[90 190 255];
screenparms.orange=[255 90 0];

% Choose fonts likely to be installed on this platform
switch computer
    case 'MAC2',
        screenparms.serifFont = 'Bookman';
        screenparms.sansSerifFont = 'Arial'; % or Helvetica
        screenparms.symbolFont = 'Symbol';
        screenparms.displayFont = 'Impact';
    case 'PCWIN64'
        screenparms.serifFont = 'Bookman Old Style';
        screenparms.sansSerifFont = 'Arial';
        screenparms.symbolFont = 'Symbol';
        screenparms.displayFont = 'Impact';
    otherwise
        error(['Unsupported OS: ' computer]);
end


 