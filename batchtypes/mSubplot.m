function mAxe = mSubplot(Fig, row, col, index,  margins, paddings)
    narginchk(4, 6);
    nSize = [1,1];
    if nargin < 5
        margins = [0.03; 0.03; 0.08; 0.08];
        paddings = 0.01 * ones(1, 4);
    end

    if nargin < 6
        paddings = 0.01 * ones(1, 4);
    end

    % nSize = [nX, nY]
    nX = nSize(1);
    nY = nSize(2);

    % paddings or margins is [Left, Right, Bottom, Top]
    divWidth = (1 - paddings(1) - paddings(2)) / col;
    divHeight = (1 - paddings(3) - paddings(4)) / row;
    rIndex = ceil(index / col);

    if rIndex > row
        error('index > col * row');
    end

    cIndex = mod(index, col);

    if cIndex == 0
        cIndex = col;
    end

    divX = paddings(1) + divWidth * (cIndex - 1);
    divY = 1 - paddings(4) - divHeight * (rIndex + nY - 1);
    axeX = divX + margins(1) * divWidth * nX;
    axeY = divY + margins(3) * divHeight * nY;

    nX = length(unique(axeX));
    nY = length(unique(axeY));
    axeWidth = (1 - margins(1) - margins(2)) * divWidth * nX + (nX - 1) * 0.5 * margins(1);
    axeHeight = (1 - margins(3) - margins(4)) * divHeight * nY + (nY - 1) * 0.5 * margins(3);
    
    axeX = axeX(1);
    axeY = axeY(1);

    % divAxe = axes(Fig, "Position", [divX, divY, divWidth * nX, divHeight * nY], "Box", "on");
    mAxe = axes(Fig, "Position", [axeX, axeY, axeWidth, axeHeight], "Box", "on");

    return;
end
