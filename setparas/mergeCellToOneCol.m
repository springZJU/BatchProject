function res = mergeCellToOneCol(data)
    [m n] = size(data);
    if n == 1
        res = data;
    else
        for M = 1:m
            res{M,1} =  data(M,:);
        end
    end
end