function res = minusAdjacent(data , method)
narginchk(1 , 2);
if nargin == 1
    method = 1; % by row
end
[m , n] = size(data);
if all([m n] == 1)
    res = data;
elseif m == 1 % one row
    for i = 1 : n - 1
        res(1 , i) = data(1 , i) - data(1 , i + 1);
    end
elseif n == 1 % one column
    for i = 1 : m - 1
        res(i , 1) = data(i , 1) - data(i + 1 , 1);
    end
else
    if method == 1 % by row
        for i = 1 : m
            for j = 1 : n - 1
                res(i , j) = data(i , j + 1) - data(i , j);
            end
        end
    else % by column
        for i = 1 : m - 1
            for j = 1 : n
                res(i , j) = data(i + 1 , j) - data(i , j);
            end
        end
    end
end
end
