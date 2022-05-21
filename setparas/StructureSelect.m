function Struct=StructureSelect(Struct,varargin)
if ~isempty(Struct)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
    if iscell(varargin{i+1})
        for j=1:length(varargin{i+1})
            if j==1
                buffer=Struct(contains({Struct.(varargin{i})},varargin{i+1}{j}));
            else
                buffer=[buffer;Struct(contains({Struct.(varargin{i})},varargin{i+1}{j}))];
            end
        end
        Struct=buffer;
    else
        Struct=Struct(contains({Struct.(varargin{i})},varargin{i+1}));
    end
end
end
end

