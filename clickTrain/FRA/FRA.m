function Fig = FRA(varargin)

    narginchk(0, 1);

    if nargin == 0
%         dataPath = 'E:\RATCLICK\LinearArrayLfp\AC\20220413\ratA_A6o25V3o1\ClickTrainToneCFThr94\data.mat';
    else
        dataPath = varargin{1};
    end

    %% Load data
    mWaitbar = waitbar(0, 'Data loading ...');
    load(dataPath);
%     data = TDT2mat(dataPath, 'CHANNEL', 1);
    waitbar(1/4, mWaitbar, 'Data loaded');

    %% Parameter Settings
    windowParams.window = [0 100]; % ms

    %% Sort
    % waitbar(1 / 4, mWaitbar, 'Sorting ...');
    % sortData = mysort(data, [], "origin-reshape", "preview");
    %
    % waitbar(2 / 4, mWaitbar, 'Plotting sort result ...');
    % plotSSEorGap(sortData);
    % plotPCA(sortData, [1 2 3]);
    % plotWave(sortData);

    %% Process
    
    result.windowParams = windowParams;
%     result.data = FRAProcess(data, windowParams);
%     Fig = plotTuning(result, "on");
      sortData.spikeTimeAll = data.sortdata(:,1);
      sortData.channelIdx = data.sortdata(:,2);

      chNum = length(unique(sortData.channelIdx)');
      chN = 0;
    for chIndex = unique(sortData.channelIdx)'
        chN = chN + 1;
        waitbar(chN / chNum, mWaitbar, ['Processing ...  Ch' num2str(chIndex+1) ]);
        result.data = FRAProcess(data, windowParams, sortData, chIndex);
        waitbar(chN / chNum, mWaitbar, ['Plotting process result ...  Ch' num2str(chIndex+1) ]);
        Fig = plotTuning(result, "on");
        saveas(Fig, strrep(dataPath,'data.mat', ['Ch' num2str(chIndex+1) '.jpg']));
        close(Fig);
    end
    save('stimParams.mat','chNum'); 
    waitbar(1, mWaitbar, 'Done');
    close(mWaitbar);

    return;
end
