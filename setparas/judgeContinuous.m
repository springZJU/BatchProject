function arrset = judgeContinuous(A)
A = sort(A);
c1 = min(A);
arrset = cell(0,0);
while(c1<numel(A))
    c2 = 0;
    while (c1+c2+1<=numel(A)&&A(c1)+c2+1==A(c1+c2+1))
        c2 = c2+1;
    end
    if(c2>=1)
        arrset= [arrset;(A(c1:1:c1+c2))];
    end
    c1 = c1 + c2 +1;
end
% fprintf('有%d组连续数：\n',numel(arrset))
% celldisp(arrset) % 显示这些连续数
