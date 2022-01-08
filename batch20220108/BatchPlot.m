clear all
clc
batchtype =  'Delelte Items' ;
EvalStructureSelect = EvalCellParaStr('CellAll','ProtocolName','DurOdd');  % 
Para = SetUserPara('EvalStructureSelect',EvalStructureSelect,'ChAll',1,...%     'CertainPath',{'RawDataResultByTrial'},...
    'LoadIndividualData',false,'UpdateIndividualData',false,...
    'PlotCh',1,'Wavelet','morlet','FsNew',300,'DownSampleRate',60,'CopyRootPath','F:\gym\batchres',...
    'DeleteType','File','DeleteName','TrialParas.mat','DeleteFirstLastTrial',0,'PushRateRange',[0.4 0.6],'AmMethod','Closest',...
    'TimeFrequencyRegion',[0 3; 1.5 10],'BackgroundRegion',[-2 3],'RenameType','File','ProtocolStr','DurOdd');
switch batchtype
    case 'Generate TrialParas'
        CellParas = GenerateTrialParas(Para);
    case 'Process TrialParas'
        CellParas = ProcessTrialParas(Para);
%     case 'Plot Figures'
%         CellParas = PlotFiguresParas(Para);
    case 'Organise Figures'
        CellParas = OrganiseFiguresParas(Para);
    case 'Process IndividualData'
        CellParas = ProcessIndividualData(Para);
    case 'Delelte Items' 
        CellParas = DelelteItems(Para);
    case 'Rename Files'
        CellParas = RenameItems(Para);
    case 'Process RatNoiseSPR'
        CellParas = ProcessRatNoiseSPR(Para);
    case 'Organise RatSPR Figures'
        CellParas = OrganiseRatSPRFiguresParas(Para);
end







