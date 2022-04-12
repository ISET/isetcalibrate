function val = icalPR715WaitForData(pr,mx)
% Wait for data on the pr serial line
%
% Default waits for 25 sec
%
% 

if notDefined('mx'), mx = 25; end

val = false;   % No data

tic;
while toc < mx
    % Wait up to 25 sec for num bytes to be positive
    if pr.NumBytesAvailable > 0
        val = true;
        return;
    else
        pause(0.050);
    end
end

end

        