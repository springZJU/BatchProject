function strcell=num2strcell(vector)
    [m,n]=size(vector);

    for row=1:m
        for col=1:n
            strcell{row,col}=num2str(vector(row,col));
        end
    end
%     varargout{1}=strcell;
end