function vas_answer = run_VAS2(window,windowRect,VAS,lines,width,thick,cursor,spacing,time_limit,frameRate);
%function vas_answer = run_VAS2;

% In this mode, subjects press left arrow and right arrow to make the cursor move.
% The current mode

% when not in test mode, mute the last line !!

%{
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
scrnNum = max(Screen('Screens'));
grey = WhiteIndex(scrnNum)/2;
bgColor = grey;
[window, windowRect] = PsychImaging('OpenWindow', scrnNum, bgColor, [], [], [], 1);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
HideCursor;

VAS = {'"Anxiety"', '"Tension"', '"Avoidance"'};
width = 500; % width of line, in pixel
thick =10;   % thickness of line, in pixel
cursor.size = thick;
cursor.color = [1 0 0];
lines = line_box; 
spacing = 2;
time_limit = 5;
%}

vas_answer = [];
dif = 20; % number of pixels change with one key_press
%t = zeros(1, nmax);
Screen('TextSize',window,40);


for VAS_i = 1:length(VAS);
    
    tic;
    count = 0;
    answer = 99;
    space_press = 0;
    
    while space_press == 0
        wait_time = toc;
        %% 1.Draw the scale bar
        [xCenter, yCenter] = RectCenter(windowRect); % windowRect = [0,0,1920,1080],xCenter=960, yCenter=540
        bar_x_center = xCenter;
        bar_y_center = yCenter+200;

        baseRect = [0 0 width thick]; % width and thickness of rect/line
        bar_rect = CenterRectOnPointd(baseRect, bar_x_center, bar_y_center);  % centered_rect: xleft,ybottom,xright,ytop
        bar_x_left = bar_rect(1);
        bar_x_right = bar_rect(3);
        Screen('FillRect',window,[1 1 1],bar_rect);

        %% 2.Display question
        min_x = xCenter-(width/2+70);
        max_x = xCenter+(width/2+10);
        DrawFormattedText(window,sprintf(strcat(lines.VAS_Q,VAS{VAS_i})),500,200,[1 1 1],0,0,0,spacing);
        DrawFormattedText(window,sprintf(lines.min),min_x,bar_y_center,[1 1 1]);
        DrawFormattedText(window,sprintf(lines.max),max_x,bar_y_center,[1 1 1]);

        %% 3. initialize cursor position
        if count == 0
            x_cursor = bar_x_center;
            %d = x-bar_x_center;
            %save('difference','d');
        %else
            %load difference
            %x_cursor = x-d;
        end
        y_cursor = bar_y_center; % y level will keep the same
        
        %% 4. detect key press
        [pressed,~,code] = KbCheck;
        if pressed == 1
            if code(KbName('ESCAPE')) % "esc" key
                close all;
                sca;
                break;
            elseif code(KbName('LeftArrow')) % press left, x axis minus
                x_cursor = x_cursor - dif;
            elseif code(KbName('RightArrow')) % press right, x axis plus
                x_cursor = x_cursor + dif;
            elseif code(KbName('space')) % press space for determination
                answer = (x_cursor-bar_x_left)/width; % record x value
                space_press = 1;
            end
        end
        
        count = count + 1;
        
        %% 5. Draw cursor
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

        RT = toc; % record RT
        if wait_time > time_limit
            answer = 99; % time's up
            break;
        end
    end
    
    %% 6. save answer
    vas_answer(:,VAS_i) = [answer;RT];
    WaitSecs(0.3);
end

Screen('TextSize',window,45);

%sca;
