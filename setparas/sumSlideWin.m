function res = sumSlideWin(data,winSize)
    narginchk(2,2);
    if max(size(data)) < winSize
        error('length of longest dimention is smallize than winSize');
    else
        for i = 1 : length(data) - (winSize - 1)
            res(i) = sum(data(i : i+winSize - 1));
        end
    end
end
