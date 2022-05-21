function res = uniqueCount(data,colIdx)
% use certain column(colIdx) to get unique element number and count
buffer = unique(data(:,colIdx));
colN = size(data,2);
rowN = length(buffer);
res = cell(rowN,colN);
res(:,colIdx) = num2cell(buffer);
for j = 1:colN
    for i = 1:rowN
    if j == colIdx
        res{i,colN+1} = sum(data(:,colIdx) == buffer(i));
    else
        buffer2 = data(:,j);
        res{i,j} = buffer2(data(:,colIdx) == buffer(i));
    end
    end
end
        
    