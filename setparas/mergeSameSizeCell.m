function res = mergeSameSizeCell(data)
res = [];
for i = 1 : numel(data)
    res = [res data{i}];
end