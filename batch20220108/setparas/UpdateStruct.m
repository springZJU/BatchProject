function S1 = UpdateStruct(S1,S2,OverlapField)
FieldS1 = fields(S1);
FieldS2 = fields(S2);
LengthS1 = size(S1,1);
LengthS2 = size(S2,1);
%% If true, add new field to S1
count = 0;
for j = 1:LengthS2
    if ~isempty(find(strcmp({S1.(OverlapField)},S2(j).(OverlapField))))
        Ind = find(strcmp({S1.(OverlapField)},S2(j).(OverlapField)));
    for i = 1:length(FieldS2)
        if ~isempty(S2(j).(FieldS2{i}))
        S1(Ind).(FieldS2{i}) = S2(j).(FieldS2{i});
        end
    end
    else
        count = count+1;
        for i = 1:length(FieldS2)
        S1(LengthS1+count).(FieldS2{i}) = S2(j).(FieldS2{i});
        end
    end
end

end