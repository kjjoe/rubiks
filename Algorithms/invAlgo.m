% function invAlgo
%
% Based on the input algorithm string, output the algorithm that does the
% exact oppoisite. Essentially undo the function.
%
% input:  
%    - algo_in: an algorithm of type string
%
% output: 
%    - algo_out: an algorithm of type string


function algo_out = invAlgo(algo_in)

algo = convertStringsToChars(algo_in);
moves = split(algo,' ');
movesout = moves;
for i = 1:length(moves)
    if length(moves{i}) == 2
        if moves{i}(2) == "'"
            movesout{i}(2) = [];
        end
    else
        movesout{i}(2) = "'";
    end
end

movesout = flip(movesout);

algo_out = strjoin(movesout,' ');

end