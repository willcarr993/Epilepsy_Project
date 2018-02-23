function resp = WaitSyncPulse(window,in_scanner)

resp = 0;
dlog = 'Press space bar to begin';
if (in_scanner) % open the serial port
    dlog = 'Waiting for scanner';
    if (ismac)
        SerialComm( 'open', 1 );
        SerialComm( 'purge', 1);
    else
        %% Windows
        sport = serial('COM1');
        fopen(sport);
    end
end

%after all initialization is done, sit and wait for scanner synch (or
%space bar)
Screen(window,'FillRect',BlackIndex(window)); % clear to black
DrawFormattedText(window,dlog,'center','center',WhiteIndex(window));
Screen(window,'Flip');  % put offscreen buffer onto screen

resp=0; read_sport=0;
KbClear();
keycode = 0;
while ~resp && ~read_sport
    if (in_scanner)
        if (ismac)
            read_sport = myreadSerial(1);
        else
            read_sport = myreadSerial(sport);
        end
    end
    if read_sport;
        resp = 1;
        break;
    end
    [ keypressed, check_time, keycode ] = KbCheck();
    if (keypressed)
        if (strcmp(KbName(keycode),'space'))
            resp = 1;
            break;
        elseif (strcmp(KbName(keycode),'ESCAPE'))
            resp = -1;
            break;
        else
            Screen(window,'FillRect',BlackIndex(window)); % clear to black
            DrawFormattedText(window,dlog,'center','center',WhiteIndex(window));
            DrawFormattedText(window,KbName(keycode),'center',10,WhiteIndex(window));
            Screen(window,'Flip');  % put offscreen buffer onto screen
            WaitSecs (0.2);
            Screen(window,'FillRect',BlackIndex(window)); % clear to black
            DrawFormattedText(window,dlog,'center','center',WhiteIndex(window));
            Screen(window,'Flip');  % put offscreen buffer onto screen

        end
    end
end
if (in_scanner)
	if (ismac)
		SerialComm( 'close', 1 );
	else
		%% Windows
		fclose(sport);
	end
end


