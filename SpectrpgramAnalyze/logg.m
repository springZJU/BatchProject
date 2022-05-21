function res=logg(n,m)
    [row,col]=size(m);
    for i=1:row
        for j=1:col
            res(i,j)=log(m(i,j))/log(n);
        end
    end
end