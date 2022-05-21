function res = diffSizeCell(data)
if length(data) ~= 1

    % if data is row vector, turn data to colomn vector
    if size(data,1) == 1
        data = data'; 
    end

    % get the length of longest cell in the cell array
    cellLen = cellfun(@length,data); 

    % put elements into arrayNew
    arrayNew = cell(1,max(cellLen));
    for cellN = 1:size(data,1)
        for eleN = 1:cellLen(cellN)
            arrayNew{eleN} = [arrayNew{eleN} data{cellN}(eleN)];
        end
    end
    % calculate mean,std,se of cells in arrayNew
    meanBuffer = num2cell(cellfun(@mean,arrayNew));
    stdBuffer = num2cell(cellfun(@std,arrayNew));
    seBuffer = num2cell(cellfun(@std,arrayNew)./sqrt(cellfun(@length,arrayNew)));
    res = struct('mean',meanBuffer,'std',stdBuffer,'se',seBuffer);


else
    res.mean = mean(data{1});
    res.std = std(data{1});
    res.se = res.std/sqrt(length(data{1}));
end

