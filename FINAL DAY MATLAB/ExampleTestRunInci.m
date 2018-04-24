try
    % Setup screen in Psychtoolbox
    screenNum=0;  % which screen to put things on
    OrigScreenLevel = Screen('Preference','Verbosity',1);  % Set to less verbose output
    [window, rect] = Screen(screenNum,'OpenWindow');  % Open the screen
    Screen('TextSize',window,36);
    KbName('UnifyKeyNames');
    [xCenter, yCenter] = RectCenter(rect);
    fixCrossDimPix = 40;
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    talpha = 0.3;
    falpha = 0.2;

    img = imread('Examples/WhiteSock.jpg');

    Screen(window,'FillRect',WhiteIndex(window)); % clear to black
    DrawFormattedText(window,'This is an Example Test Run\n\n Please use the left and right arrows to respond\n\n\n\nPress spacebar when you are ready to begin.','center','center',BlackIndex(window));
    Screen(window,'Flip');  % put offscreen buffer onto screen
    Screen(window,'FillRect',WhiteIndex(window)); % clear to black
    Screen(window,'PutImage',img);  % draw onto offscreen buffer
    KbWait; 

    Screen(window,'Flip');  % put offscreen buffer onto screen
    img = imread('Examples/FryingPan.jpg');
    Screen(window,'FillRect',WhiteIndex(window)); % clear to black
    Screen(window,'PutImage',img);  % draw onto offscreen buffer
    WaitSecs(0.2);
    keypressed = 0;
    while keypressed ~= 115 && keypressed ~= 114
        [~,keycode,~] = KbWait;
        if ~isempty(keycode)
            keypressed = find(keycode);
        end
    end
    Screen (window, 'Flip')
    img = imread('Examples/ColourSock.jpg');
    Screen(window,'FillRect',WhiteIndex(window)); % clear to black
    Screen(window,'PutImage',img);  % draw onto offscreen buffer
    WaitSecs(0.2);
    keypressed = 0;
    while keypressed ~= 115 && keypressed ~= 114
        [~,keycode,~] = KbWait;
        if ~isempty(keycode)
            keypressed = find(keycode);
        end
    end

    Screen (window, 'Flip')
    img = imread('Examples/FryingPan.jpg');
    Screen(window,'FillRect',WhiteIndex(window)); % clear to black
    Screen(window,'PutImage',img);  % draw onto offscreen buffer
    WaitSecs(0.2);    
    keypressed = 0;
    while keypressed ~= 115 && keypressed ~= 114
        [~,keycode,~] = KbWait;
        if ~isempty(keycode)
            keypressed = find(keycode);
        end
    end

    Screen (window, 'Flip')
    img = imread('Examples/Boomerang.jpg');
    Screen(window,'FillRect',WhiteIndex(window)); % clear to black
    Screen(window,'PutImage',img);  % draw onto offscreen buffer
    WaitSecs(0.2);    
    keypressed = 0;
    while keypressed ~= 114 && keypressed ~= 115
        [~,keycode,~] = KbWait;
        if ~isempty(keycode)
            keypressed = find(keycode);
        end
    end


    Screen (window, 'Flip')
    WaitSecs(0.2);    
    keypressed = 0;
    while keypressed ~= 115 && keypressed ~= 114
        [~,keycode,~] = KbWait;
        if ~isempty(keycode)
            keypressed = find(keycode);
        end
    end

    time = GetSecs() + 0.2;
    [BaselineAns] = DoPerceptualBaselineScanner(window, time, talpha, falpha);

    if BaselineAns == 1
        BaselineAns = 114;
    elseif BaselineAns == 4
        BaselineAns = 115;
    end
    WaitSecs(0.2);    
    keypressed = 0;
    while keypressed ~= BaselineAns
        [~,keycode,~] = KbWait;
        if ~isempty(keycode)
            keypressed = find(keycode);
        end
    end

    Screen('CloseAll');
    Screen('Preference','Verbosity',OrigScreenLevel);
catch
    Screen('CloseAll');
    Screen('Preference','Verbosity',OrigScreenLevel);
end







