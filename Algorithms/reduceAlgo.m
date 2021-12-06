% function reduceAlgo
%
% Based on the input algorithm string, remove redudancies such as F F' and
% also combine moves such as FFF into F' or FF into F2.
%
% input:  
%    - algo:      an algorithm of type string
%
% output: 
%    - algo_new:  the reduced algorithm of type string
%
% See also: doAlgorithm.m for testing

function algo_new = reduceAlgo(algo)
    %% initialize
   tog = char(algo);
    tog(tog == ' ') = [];
    t = tog;
    moveset = 'DFRUBLMESXYZ';
%     moveset = 'Y'; % debug
    for mindex = 1:12
        % locations for specific move
        move = moveset(mindex);
        
        % write in all the doubles
        locdouble = (t == '2');
        loc = (t == move);
        t(circshift(loc,1) & locdouble) = move;
        
        % remove F F'  and then F' F
        locprime = (t == '''');
        for i = 1:2
            if i == 1
                look = [1,-1];
            else
                look = [-1,0,1];
            end
            loc = double(t == move);
            loc(loc & circshift(locprime,-1)) = -1; % mark backwards movement

            redudant = (conv(loc,look,'same') == -2) ;
            if i == 2
                redudant = circshift(redudant,-1);
            end
            redudant([find(redudant == 1) + 1 , find(redudant == 1) + 2]) = 1; % remove these points as well
            t(redudant) = ' ';
        end
        % update loc
        t(t==' ') = [];
        loc = double(t == move);
        locprime = (t == '''');
        loc(loc & circshift(locprime,-1)) = -1; % mark backwards movement

        % find streaks
        nz = find(loc ~= 0);
        streakvec = zeros(size(loc));
        i = 1;
        while i <= length(nz)
            first = loc(nz(i));
            cont = 1;
            j = 1;
            streak = 1;
            while cont == 1 &&  (nz(i) + j ) <= length(loc)
                if first == 1
                    if first == loc(nz(i) + j)
                        streak = streak + 1;
                    else
                        cont = 0;
                    end
                    j = j + 1;
                else % weird logic if streaks of F'F'F'
                    try
                        if isequal([-1,0] , loc(nz(i)+j+1 : nz(i)+j+2 ))
                            streak = streak + 1;
                        else
                            cont = 0;
                        end
                    catch
                        cont = 0;
                    end
                    j = j + 2;
                end

            end
            if first == 1
                streakvec( nz(i) ) = streak;
            else % weird logic if streaks of F'F'F'
                streakvec( nz(i) ) = -streak;
            end
            i = i + streak;
        end

        % remove streak
        streaknew = mod(streakvec,4);
        nz = find(streakvec > 1);

        for i = 1:length(nz)
            tmp = repmat(' ',1,streakvec(nz(i)));
            if streaknew(nz(i)) == 1
                tmp(1) = move;
            elseif streaknew(nz(i)) == 2
                tmp(1:2) = [move, '2'];
            elseif streaknew(nz(i)) == 3
                tmp(1:2) = [move, ''''];
            end

            t(nz(i) : nz(i)+streakvec(nz(i))-1) = tmp;
        end
        
        % remove streak negatives
        nz = find(streakvec < -1);

        for i = 1:length(nz)
            tmp = repmat(' ',1,2*abs(streakvec(nz(i))));
            if streaknew(nz(i)) == 1
                tmp(1) = move;
            elseif streaknew(nz(i)) == 2
                tmp(1:2) = [move, '2'];
            elseif streaknew(nz(i)) == 3
                tmp(1:2) = [move, ''''];
            end

            t(nz(i) : nz(i)+2*abs(streakvec(nz(i)))-1) = tmp;
        end
    end

    %% convert back
    t(t==' ') = [];
    locprimedouble = circshift((t == '''') + (t == '2'),-1);
    algo_new = [];
    i = 1;
    while i <= length(t)
        if locprimedouble(i) == 1
            tmp = t(i:i+1);
            i = i + 2;
        else
            tmp = t(i);
            i = i + 1;
        end

        algo_new = join([algo_new, string(tmp)]);
    end


end