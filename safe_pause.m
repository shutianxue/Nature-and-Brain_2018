function safe_pause(window,bgColor,safe_time);
Screen('FillRect',window,bgColor);
Screen('flip',window);
WaitSecs(safe_time);
