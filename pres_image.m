function pres_image(window,windowRect,version,scale_i,image_i,bgColor,time_img,proportion_of_screen);

% when not in test mode, mute the last line !!

%% screen
%{
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
scrnNum = max(Screen('Screens'));
grey = WhiteIndex(scrnNum)/2;
bgColor = grey;
[window, windowRect] = PsychImaging('OpenWindow', scrnNum, bgColor, [], [], [], 1);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
HideCursor;

proportion_of_screen = 1;

% Test mode:
scale_i  = 1; % which scale: 1=0-2.5, 2=10-20, 3=31-40, 4=51-60
image_i  = 4; 
version  = 1;
time_img = 2;
%}

current_folder = pwd;
%image_name = strcat(current_folder,'\images\',2,'\',num2str(image_i),'.png');
image_name = strcat(current_folder,'\images\',num2str(scale_i),'\',num2str(image_i),'.png');
    
%% load image
full_image_read = imread(image_name);

% grayscale (version=0) or colored version (version=1)
if version == 0
    full_image_read = rgb2gray(full_image_read);
end

% cut image and only contain the "core"
[h,w,~] = size(full_image_read); % h=1080,w=1920
nonzero_row = find(full_image_read(:,:,1)); % find the row whose value is not zero (which means not black)
start = nonzero_row(1);
h_core = h-start*2;
w_core = w/2;

% only retains the core part and remove the frame
image_right = full_image_read(start:start+h_core-1,1:w_core,:);
image_left = full_image_read(start:start+h_core-1,w_core+1:end,:);

if scale_i == 4
    a=image_right;
    image_right = image_left;
    image_left = a;
end

% adjust the size of image by ratio
ratio = proportion_of_screen * 1080/h_core;

%% set and display image
% set rects locating images 
baseRect = [0,0,w_core*ratio,h_core*ratio]; % size of the image, wXh
[xCenter, yCenter] = RectCenter(windowRect);
rect = CenterRectOnPointd(baseRect, xCenter, yCenter); 

% left-eye image  
Screen('SelectStereoDrawBuffer', window, 0);
left_texture = Screen('MakeTexture', window, image_left);
Screen('DrawTexture',window,left_texture,[],rect);

% right-eye image
Screen('SelectStereoDrawBuffer', window, 1);
right_texture = Screen('MakeTexture', window, image_right);
Screen('DrawTexture',window,right_texture,[],rect);

Screen('Flip', window);

WaitSecs(time_img);
Screen('FillRect', window, bgColor);Screen('flip',window);

%KbWait;
%sca;