function res = subplotPanel(N,num,method)
buffer = [1 1; 1 2;2 2; 2 2; 2 3;...
          2 3; 2 4; 2 4; 3 3; 3 4;...
          3 4; 3 4; 4 4; 4 4; 4 4;...
          4 4; 4 5; 4 5; 4 5; 4 5;...
          5 5; 5 5; 5 5; 5 5; 5 5];
switch method
    case 'default'
        res = [buffer(N,:) num];
        eval(['subplot(' num2str(res(1)) ',' num2str(res(2)) ',' num2str(res(3)) ');']);
    case 'position'
        upBlank = 0.05; downBlank = 0.05; leftBlank = 0.05; rightBlank = 0.05;
        colSpace = 0.05; rowSpace = 0.03;
        rowNum = buffer(N,1);
        colNum = buffer(N,2);
        height = (1-(upBlank + downBlank)-(rowNum - 1)*rowSpace)/rowNum;
        width = (1-(leftBlank + rightBlank)-(colNum - 1)*colSpace)/colNum;
        initialX = leftBlank;
        initialY = 1-upBlank;
        yNum = floor((num-1)/colNum); 
        xNum = mod((num-1),colNum)+1;
        res(1) = initialX+(xNum-1)*(width+colSpace);
        res(2) = initialY-yNum*(height+rowSpace)-height;
        res(3) = width;
        res(4) = height;
        subplot('position',res);
end


