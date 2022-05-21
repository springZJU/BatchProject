function [Res ResX Index]=GetAlignRes(Data,Win,Xtick)
    Index=find(Xtick>=Win(1)&Xtick<=Win(2));
    ResX=Xtick(Index);
    Res=Data(:,Index);
end