function params = AmbiguousClassify(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);
ProtNum = 0;
for cellnum = 1:size(BufferData,1)
    ProtocolName = BufferField(ProtocolLogic&StructLogic(cellnum,:));
%     ActiveProtocolTypes = ProtocolName(contains(ProtocolName,'Active')&contains(ProtocolName,'Freq'));
    ActiveProtocolTypes = ProtocolName(contains(ProtocolName,'Active'));

    if ~isempty(ActiveProtocolTypes)
        for protypes = 1:length(ActiveProtocolTypes)
            BufferProt = BufferData(cellnum).(ActiveProtocolTypes{protypes}); % get current protocol data
            TrialParas = BufferProt.TrialParas; %evalue trialparas
            TrialParas = LabelAmbiguous(TrialParas,AmMethod); 
            TrialParas = LabelPriorRes(TrialParas);
            params.BufferData(cellnum).(ActiveProtocolTypes{protypes}).TrialParas = TrialParas;
            params.BufferData(cellnum).(ActiveProtocolTypes{protypes}).AmbiguousTrials = GetAmbiguousTrials('TrialParas',TrialParas);
            buffer = GetAmbiguousTrials('TrialParas',TrialParas);
            if ~isempty(buffer)
                ProtNum = ProtNum+1;
                cuetype = fields(buffer);
                for m = 1:length(cuetype)
                    % group all ambiguous trials in one variable
                    try
                        if ~isempty(buffer.(cuetype{m}))
                            AmbiguousTrials.(cuetype{m}) = [AmbiguousTrials.(cuetype{m}); buffer.(cuetype{m})];
                        end
                    catch
                        AmbiguousTrials.(cuetype{m}) = [];
                    end
                    %% classify ambiguous trials bases on prior reword
                    if ~exist('method')|strcmp(method,'prior')
                        try params.PriorTrialClassesAll;
                            [params.PriorCorrectRes.(cuetype{m})(:,ProtNum),params.PriorWrongRes.(cuetype{m})(:,ProtNum),params.PriorTrialClassesAll.(cuetype{m}),params.PriorTrialClasses.(cuetype{m}){ProtNum}] = AmbiguousTrialAnalysis(buffer.(cuetype{m}),'TrialClassesAll',params.PriorTrialClassesAll.(cuetype{m}),'method','prior');
                        catch
                            [params.PriorCorrectRes.(cuetype{m})(:,ProtNum),params.PriorWrongRes.(cuetype{m})(:,ProtNum),params.PriorTrialClassesAll.(cuetype{m}),params.PriorTrialClasses.(cuetype{m}){ProtNum}] = AmbiguousTrialAnalysis(buffer.(cuetype{m}),'method','prior');
                        end
                    end
                    
                    %% classify ambiguous trials based on stdnum
                    if ~exist('method')|strcmp(method,'stdnum')
                        try params.StdnumTrialClassesAll;
                            [params.StdnumRes.(cuetype{m})(:,ProtNum),params.StdnumTrialClassesAll.(cuetype{m}),params.StdnumTrialClasses.(cuetype{m}){ProtNum}] = AmbiguousTrialAnalysis(buffer.(cuetype{m}),'TrialClassesAll',params.StdnumTrialClassesAll.(cuetype{m}),'method','stdnum');
                        catch
                            [params.StdnumRes.(cuetype{m})(:,ProtNum),params.StdnumTrialClassesAll.(cuetype{m}),params.StdnumTrialClasses.(cuetype{m}){ProtNum}] = AmbiguousTrialAnalysis(buffer.(cuetype{m}),'method','stdnum');
                        end
                    end

                end
            end
        end
    end
end