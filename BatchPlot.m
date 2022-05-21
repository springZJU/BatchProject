function BatchPlot(varargin)
narginchk(0,1);

%% initalization for configuration
if nargin == 0
    batchtype = 'Organise Figures'; %'Process Passive ClickTrain'   'Process Click IndividualData'
    autoBatch = false;
    rootPath = 'E:\MonkeyLayer\zdata\rootpath';
    IndividualDataPath = 'E:\MonkeyLayer\zdata\rootpath\IndividualData.mat';
else
    batchtype = varargin{1};
    autoBatch = true;
    rootPath = 'E:\MonkeyLayer\zdata\rootpath';
    IndividualDataPath = 'E:\MonkeyLayer\zdata\rootpath\IndividualData.mat';
end
% EvalStructureSelect = EvalCellParaStr('CellAll','ProtocolName','Basic');  %
Para = SetUserPara( ...
    ...% for automatic batch
    'rootPath',rootPath,'IndividualDataPath',IndividualDataPath,'autoBatch',autoBatch,...
    ...% for Data/Channel Select
    'ChAll',16,'PlotCh',4,'spikeChSelect',[14],...
    ...'keyword',{'ACPFC','ClickTrainSSA','(Basic|Insert|HighOrder|NoiseTone|ToneClick|ShortLong|SingleClick|LongTerm)'},...
    'keyword',{'ACPFC','ClickTrainSSA','(LongTerm)'},...
    ...'keyword',{'AC','ClickTrainSSA','(LongTerm)'},...
    ...'keyword',{'MGB','Click'},...
    ...'keyword',{'Basic','(Freq)'},...
    ...% for Generate TrialParas
    'choicewin',[100 600],...
    ...% the length of data to analyze, for LFP
    'BackgroundRegion',[-2 3], ...
    ...% for ProcessTrialParas ---select datatype to analyse
    'toAnalyseLFP',false,'toAnalyseSpike',true,'toAnalyseBehavior',false, ...
    ...% for ProcessTrialParas ---IndividualData update/merge/save
    'LoadIndividualData',true,'SaveIndividualData',false,'UpdateIndividualData',true,'Fragmentation',false, ...
    ...% for ProcessTrialParas ---LFP TimeFrequency domain
    'TimeFrequencyRegion',[0 3; 1.5 10], ...
    ...% for ProcessTrialParas ---LFP wavelet
    'Wavelet','morlet','FsNew',300,'DownSampleRate',60, ...
    ...% for ProcessTrialParas ---skip Processed TrialParas ; skip plot if certain result folder exists
    'skipExisting', true,'skipProcessed', true, 'reProcess' , false,...
    ...% for ProcessIndividualData ---Choose certain protocol
    ...'ProtocolStr',{'Basic','Freq','High'},'RegionStr',{'AC'},...
    'ProtocolStr',{'Click'},'RegionStr',{'MGB'},...
    ...% for ProcessIndividualData ---preReword Effect，AmMethod--ambiguous method
    'PushRateRange',[0.4 0.6],'AmMethod','Closest',...
    ...% for OrganiseFiguresParas
    'CopyType','Folder','CopyRootPath','E:\ECoG\ECoGResult','copyLabel','Waveform',...
    ...% for DeleteItems
    'DeleteType','File','DeleteName','batchOpt.mat','DeleteFirstLastTrial',false,...
    ...% for RenameItems
    'RenameType','File');

%% choose batch types
switch batchtype
    %**********For Oddball Paradigm***********
    case 'Generate Odd TrialParas'
        CellParas = GenerateTrialParas(Para);
    case 'Process Odd TrialParas'
        CellParas = ProcessTrialParas(Para);
    case 'Process Odd IndividualData'
        CellParas = ProcessOddIndividualData(Para);
        %**********For ClickTrain Paradigm***********
    case 'Process Passive ClickTrain'
        CellParas = ProcessClickTrain(Para);
    case 'Process Click Train IndividualData'
        ProcessClickTrainSSAIndividualData(Para);
    case 'Process Click IndividualData'
        CellParas = ProcessClickIndividualData(Para);
    case 'Organise Figures'
        CellParas = OrganiseFiguresParas(Para);
    case 'Delelte Items'
        CellParas = DelelteItems(Para);
    case 'Rename Files'
        CellParas = RenameItems(Para);
    case 'Process RatNoiseSPR'
        CellParas = ProcessRatNoiseSPR(Para);
    case 'Organise RatSPR Figures'
        CellParas = OrganiseRatSPRFiguresParas(Para);
end







