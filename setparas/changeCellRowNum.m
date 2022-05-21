function res = changeCellRowNum(data)
N = length(data);
M = size(data{1},1);
for i = 1 : N
for j = 1 : M
    res{j}(i,:) = data{i}(j,:);
end
end