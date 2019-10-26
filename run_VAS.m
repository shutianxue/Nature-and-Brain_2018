function vas_answer = run_VAS(window,windowRect,VAS,lines,width,thick,cursor,spacing,time_limit,frameRate);

% In this mode, subjects move mouse to make the cursor move.
% not the current mode

% when not in test mode, mute the last line !!

%{
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
scrnNum = max(Screen('Screens'));
grey = WhiteIndex(scrnNum)/2;
bgColor = grey;
[window, windowRect] = PsychImaging('OpenWindow', scrnNum, bgColor, [], [], [], 1);
frameRate = 1/Screen('GetFlipInterval',window);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
HideCursor;

VAS = {'"Anxiety"', '"Tension"', '"Avoidance"'};
width = 500; % width of line, in pixel
thick =10;   % thickness of line, in pixel
cursor.size = thick;
cursor.color = [1 0 0];
lines.VAS_Q = 'Please move your mouse and you will see your cursor sliding on the scale.\nPress SPACE when the position of cursor represents this mood status:\n';
lines.min = 'min';
lines.max = 'max';
spacing = 2;
time_limit = 5;
%}

vas_answer = [];
nmax = round(time_limit * frameRate);
%t = zeros(1, nmax);
Screen('TextSize',window,40);


for VAS_i = 1:length(VAS);
    
    tic
    count = 1;
    pressed = 0;
    answer = 99;
    while (count < nmax) && ~any(pressed)
        [x,y] = GetMouse(window);
        [x,~] = RemapMouse(window, 'AllViews', x, y); % perform geometric display correction
        
        %% Draw the scale bar
        [xCenter, yCenter] = RectCenter(windowRect); % windowRect = [0,0,1920,1080],xCenter=960, yCenter=540
        bar_x_center = xCenter;
        bar_y_center = yCenter+200;
        
        baseRect = [0 0 width thick]; % width and thickness of rect/line
        bar_rect = CenterRectOnPointd(baseRect, bar_x_center, bar_y_center);  % centered_rect: xleft,ybottom,xright,ytop
        bar_x_left = bar_rect(1);
        bar_x_right = bar_rect(3);
        Screen('FillRect',window,[1 1 1],bar_rect);
             
        %% Ask question
        min_x = xCenter-(width/2+70);
        max_x = xCenter+(width/2+10);
        DrawFormattedText(window,sprintf(strcat(lines.VAS_Q,VAS{VAS_i})),500,200,[1 1 1],0,0,0,spacing);
        DrawFormattedText(window,sprintf(lines.min),min_x,bar_y_center,[1 1 1]);
        DrawFormattedText(window,sprintf(lines.max),max_x,bar_y_center,[1 1 1]);
        
        %% Draw cursor
        if count == 1
            x_cursor = bar_x_center;
            d = x-bar_x_center;
            save('difference','d');
        else
            load difference
            x_cursor = x-d;
        end
        
        y_cursor = bar_y_center;
        
        if x_cursor <= bar_x_right && x_cursor >= bar_x_left
            Screen('DrawDots', window, [x_cursor;y_cursor], cursor.size,cursor.color,[],4); % 4: draws a square
        elseif  x_cursor >= bar_x_right
            Screen('DrawDots', window, [bar_x_right;y_cursor], cursor.size,cursor.color,[],4);
            x_cursor = bar_x_right;
        elseif x_cursor <= bar_x_left
            Screen('DrawDots', window, [bar_x_left;y_cursor], cursor.size,cursor.color,[],4);
            x_cursor = bar_x_left;
        end
        Screen('Flip', window);
        
        %% Handle key
        
        [pressed,~,code] = KbCheck;
        if pressed == 1
            RT = toc; % record RT
            if code(KbName('ESCAPE')) == 1 % "esc" key
                close all;
                sca;
                break;
            elseif code(KbName('space')) == 1
                % indicate record of x value
                answer = (x_cursor-bar_x_left)/width; 
            end
            if RT > time_limit
                answer = 99; % time's up
            end
            
        end
        
        count = count + 1;
    end
    
    % save answer
    vas_answer(:,VAS_i) = [answer;RT];
    WaitSecs(0.3);
        
end

Screen('TextSize',window,45);

%sca;
