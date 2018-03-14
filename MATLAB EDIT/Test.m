for i = 1:2
    WaitSecs(0.1);
    [keyisdown,~,keyname] = KbCheck();
    fprintf('%d \n', keyisdown)
    keyname
end

