function pr_box = run_PR(window,lines,spacing,time_limit);
%function pr_box = run_PR;

% this script displays a question and requests key response from subject
% when not in test mode, mute the last line !!

%{
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
scrnNum = max(Screen('Screens'));
grey = WhiteIndex(scrnNum)/2;
bgColor = grey;
[window, ~] = PsychImaging('OpenWindow', scrnNum, bgColor, [], [], [], 1);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
HideCursor;

spacing = 2;
lines = line_box;
time_limit = 30;
%}

DrawFormattedText(window,sprintf(strcat(lines.PR_Q,lines.PR_A)),500,'center',[1 1 1],0,0,0,spacing);
Screen('flip',window);

%% get key
press = 0;
keys = 49:53; % this is for 1:5
              % use KbName('') to find a key's keyNumber
              % alert for retriving letters: 1 is '1!', 2 is '2@' ...
tic;
while press == 0
    wait_time = toc;
    [press,~,code] = KbCheck; % key is pressed
    RT = toc; % record RT
    
    if code(KbName('ESCAPE')) == 1
        close all;
        sca;
        %return;
    else
        pr = intersect(find(code),keys);
        if isempty(pr)% when the wrong key is pressed, save 99
            pr = 99+48;
        end
    end
    
    if wait_time > time_limit
        pr = 99+48; % if make a response after time's up, save 99
        break;
    end
end 

pr = pr-48;

%dc hack: vivian, if you do the below, then RT is wiped out in cases where two responses are picked up.  Suggest to try it this way (as below) so that we choose to take only the first response, and preserve the RT

if length(pr) > 2
	pr_box = [pr(1), RT];
else
	pr_box = [pr, RT];
end

%pr_box = [pr,RT];
%if length(pr_box) > 2 
%    pr_box = pr_box(1:2);
%end

%sca;
