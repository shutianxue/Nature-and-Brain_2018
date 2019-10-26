function RunExp(subjectID, version)
%% Description
% Input:
% subjectID: must be a string, usually 3-digit numbr, e.g., '001'
% version: 1 = colored images
%          0 = grey-scale images

% For procedure, please refer to <Instruction>

%% checking input
if ~ischar(subjectID)
    fprintf('Warning: "subjectID" must be a string.\nHint: Did you forget to add the single quotation mark?\n');
    return
end
 

%% Screen
PsychDefaultSetup(2); 
Screen('Preference', 'SkipSyncTests', 1);
scrnNum = max(Screen('Screens'));
grey = WhiteIndex(scrnNum)/2;
bgColor = grey;
[window, windowRect] = PsychImaging('OpenWindow', scrnNum, bgColor, [], [], [], 1);
frameRate = 1/Screen('GetFlipInterval',window);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
HideCursor;

%% setting
% 1. general
num_scale = 4;
        % no. of image groups categorized by ratio of green coverage
        % = no. of subfolders in the folder called "images", named by numbers:
        % default: 4 --> 1=0-2.5, 2=10-20, 3=31-40, 4=51-60
        
round = 3; % no. of exp rounds (stimulus+VAS)
           % default: 3

% rng('shuffle');
seq_scale = randperm(num_scale);

% time
time_limit = 10; % max time for answering one question (in secs)
                 % default: 10I
safe_time = 0.3; % short pause to separate presses
                 % default: .3
                 
rest_PR = 1;     % default: 1
rest_time1 = 2*60; % compulsory rest time (in minutes) between rounds 
                   % default: 2(mins)*60
rest_time2 = 5*60; % compulsory rest time (in minutes) between scales
                   % default: 5(mins)*60
                   
% 2. image
num_img = 15; % no. of images retrived from one scale, location: pwd/images/subfolders
              % default: 15 pictures; 
time_img = 8; % how long each image lasts, in secs
              % default: 8 secs
proportion_of_screen = 1; % size_image : size_screen
              % default: 1

% 3. VAS
VAS_str = {'<Anxiety>', '<Tension>', '<Avoidance>'};
width = 500;    % width of bar, in pixel
thickness = 10; % thickness of bar, in pixel
cursor.size = thickness;
cursor.color = [1 0 0];
lines = line_box;
spacing = 1.5;

%% Step 1: before Loop
VAS_record = ones(2*num_scale, (round+1)*3+1)*99;
Screen('TextSize', window, 35);

% makes texts bigger!
Screen('TextSize',window,45);

% Line: welcome 
DrawFormattedText(window,lines.welcome,400,'center',[1 1 1],0,0,0,spacing);
Screen('flip',window);
KbWait;
safe_pause(window,bgColor,safe_time);

%% Step 2: VAS + image + gap Loop (4 times, each for one scale)
for scale_i = 1:num_scale
    row_start = scale_i*2-1;
    row_end   = scale_i*2;
    
    scale = seq_scale(scale_i);
    
    % 1st VAS
    vas_record = run_VAS2(window,windowRect,VAS_str,lines,width,thickness,cursor,spacing,time_limit,frameRate);
    VAS_record(row_start,1) = scale;
    VAS_record(row_start:row_end,2:4) = vas_record;
    safe_pause(window,bgColor,safe_time);
    
    for round_i = 1:round
        col_start = (round_i+1)*3-1;
        col_end   = (round_i+1)*3+1;
        % line: start a new round
        DrawFormattedText(window,sprintf(lines.prompt),500,'center',[1 1 1],0,0,0,spacing);
        Screen('flip',window);
        WaitSecs(safe_time);
        KbWait;
        
        safe_pause(window,bgColor,safe_time);
        
        % present image (15 pieces for one scale, each 8 secs)
        for img_i = 1:num_img
            rng('shuffle')
            img_seq = randperm(num_img);
            image_i = img_seq(img_i);
            pres_image(window,windowRect,version,scale,image_i,bgColor,time_img,proportion_of_screen);
            WaitSecs(safe_time); % intro blank between images
        end
        safe_pause(window,bgColor,safe_time);
        
        % VAS
        vas_record = run_VAS2(window,windowRect,VAS_str,lines,width,thickness,cursor,spacing,time_limit,frameRate);
        safe_pause(window,bgColor,safe_time);      
              
        % save data
        VAS_record(row_start:row_end,col_start:col_end,:) = vas_record;
        
        if round_i ~= round
            % compulsory rest between <rounds>
            DrawFormattedText(window,sprintf(lines.rest_com,rest_time1),500,'center',[0 1 1],0,0,0,2);
            Screen('flip',window);
            WaitSecs(rest_time1);

            % press a key to continue
            Screen('FillRect',window,bgColor);Screen('flip',window);
            DrawFormattedText(window,lines.rest_continue,'center','center',[0 1 1],0,0,0,2);
            Screen('flip',window);
            WaitSecs(safe_time);
            KbWait;
            Screen('FillRect',window,bgColor);Screen('flip',window);
        end
    end

    % Gap + Inform subjects of the new scale
    if scale_i ~= num_scale
        DrawFormattedText(window,sprintf(strcat(lines.rest_reminder,lines.rest_com),num_scale-scale_i,rest_time2),500,'center',[0 1 1],0,0,0,2);
        Screen('flip',window);
    end
    % compulsory rest between <scales>
    if scale_i ~= num_scale % not when the last scale is finished
        WaitSecs(rest_time2);
        Screen('FillRect',window,bgColor);Screen('flip',window);
        DrawFormattedText(window,lines.rest_continue,'center','center',[0 1 1],0,0,0,2);
        Screen('flip',window);
        WaitSecs(safe_time);
        KbWait;
        Screen('FillRect',window,bgColor);Screen('flip',window);
        safe_pause(window,bgColor,safe_time);
    end
end
%}
                          
% save data
Data.subjectID = subjectID;
Data.version   = version;
Data.VAS       = VAS_record;  % scale# | avoidance# | tension# | anxiety# || ...
                          %              RT 1,        RT 2,      RT 3     || ...
                          %(number of blocks = number of rounds+1)
                          %(number of rows = number of scales*2)
CreateDataFile(Data);

%% Step 3: Preference test (PR)
% prepare image
img_index_box = fullfact([num_scale,num_img]);
num_pr = size(img_index_box,1);
rng('shuffle')
img_index_box_rand = img_index_box(randperm(size(img_index_box,1)),:);
pr_record = ones(num_pr,4)*99;

% Instruction
Screen('FillRect',window,bgColor);Screen('flip',window);
DrawFormattedText(window,lines.PR ,500,'center',[1 1 1],0,0,0,spacing);
Screen('flip',window);
KbWait;
safe_pause(window,bgColor,safe_time);
Screen('FillRect',window,bgColor);Screen('flip',window);

% Loop
for img_pr_i = 1:num_pr
    % present image
    scale_i = img_index_box_rand(img_pr_i,1);
    image_i = img_index_box_rand(img_pr_i,2);
    pres_image(window,windowRect,version,scale_i,image_i,bgColor,time_img,proportion_of_screen);
    WaitSecs(); 

    % ask and collect answer
    pr_box = run_PR(window,lines,spacing,time_limit); % pr_box = [pr,RT];
    safe_pause(window,bgColor,safe_time);
    pr_record(img_pr_i,1:4) = [scale_i,image_i,pr_box];
    
   % give a rest
    if img_pr_i == floor(num_pr/(rest_PR+1))
    	DrawFormattedText(window,lines.rest_PR,'center','center',[0 1 1],0,0,0,2);
        Screen('flip',window);
        WaitSecs(safe_time);
        KbWait;
    end
end

%% Step 4: save data I
Data.PR = pr_record; % scale#, image#,  preference(1-5), RT
CreateDataFile(Data);

%% Step 5: Ending
DrawFormattedText(window,lines.ending,700,'center',[0 1 1],0,0,0,2);Screen('flip',window);
WaitSecs(1.5);
sca;
