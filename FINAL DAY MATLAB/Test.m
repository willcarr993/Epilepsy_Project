% WaitSecs(1);
% for i = 1:100
%     WaitSecs(0.1);
%     [keyisdown,~,keyname] = KbCheck();
%     fprintf('%d \n', keyisdown)
%     find(keyname)
%     if find(keyname)
%         break
%     end
% end
keypressed = 0;
while (keypressed ~= 115) && (keypressed ~= 114)
    [~,keycode,~] = KbWait;
    if ~isempty(keycode)
        keypressed = find(keycode);
    end
end

