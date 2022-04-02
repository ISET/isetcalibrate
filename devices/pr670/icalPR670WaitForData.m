function val = icalPR670WaitForData(pr,mx)
% Wait for data on the pr serial line
%

if notDefined('mx'), mx = 25; end

val = false;   % No data

tic;
while toc < mx
    % Wait up to 15 sec for num bytes to be positive
    if pr.NumBytesAvailable > 0
        val = true;
        return;
    end
end

end

        