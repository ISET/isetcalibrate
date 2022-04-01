function icalPR670write(pr,cmdStr)
% Push the command to the PR670
%
%

verbose = true;
if verbose, disp(cmdStr); end

for i = 1:length(cmdStr)
    pr.write(upper(cmdStr(i)),'char');
    pause(0.05)
end

end
