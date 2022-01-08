function Para = GetProtocolPara(TrialParas,ProtocolName,Para)
    if contains(ProtocolName,'Active')
            behavtype=1:3;  %Push/Nopush/All
            AP='Active';
    elseif contains(ProtocolName,'Passive')
            behavtype=2; %Nopush only
            AP='Passive';
    end
   
    CueTypes = unique({TrialParas.CueType});
    CueTypes(contains(CueTypes,'control'))=[]; 
    if length(CueTypes)>1
        CueTypes{end+1}=['all']; 
    end
    Para.AP = AP;
    Para.CueTypes = CueTypes;
    Para.behavtype = behavtype;
    Para.Diff = 1:length(unique([TrialParas.FreqDiff TrialParas.IntDiff TrialParas.DurDiff]));

end


