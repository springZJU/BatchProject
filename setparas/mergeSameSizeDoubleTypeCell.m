function res = mergeSameSizeDoubleTypeCell(data)
[M N] = size(data{1,1});
res = cell(M,N);
for m = 1:M
    for n = 1:N
        for i = 1:numel(data)
            res{m,n} = [res{m,n} ; data{i}(m,n)];
        end
    end
end
            
