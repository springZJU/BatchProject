function varargout = clickTrainSSAWinsSpikeFunc(params,datapath,varargin)
if nargin<2
    disp('Please input datapath information')
    return
else

    for i = 1:2:length(varargin)
        eval([ varargin{i} '=varargin{i+1};']);
    end
    eval([GetStructStr(Para) '=ReadStructValue(Para);']);


    %% check if stimParams exist
    if exist(strrep(datapath,'data.mat','batchOpt.mat'),"file") && 1
        load('batchOpt.mat');
    else

        %% generate ClickTrain SSA Stimpara
        batchOpt = generateClickTrainSSAStimparaSpike(params,datapath);

        %% classfy click trains by std number and dev
        batchOpt = SSAStdDevClassifySpike(batchOpt);
        save batchOpt.mat batchOpt

        %% evalue output
        stimParams = SelectStructField(batchOpt,{'rez','stimType','stimPara','stimStr'});
        save stimParams.mat stimParams

    end


    %% plot results
%     plotClickTrainSSAFig(batchOpt);
if contains(datapath,'LongTerm')
    plotClickTrainSSAFigLongTermSpike(batchOpt);

else
%     plotClickTrainSSAFigForYuSpike(batchOpt);
end
end

