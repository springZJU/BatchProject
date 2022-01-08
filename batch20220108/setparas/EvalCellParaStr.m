function EvalStr = EvalCellParaStr(Varname,varargin)
    EvalStr = ['CellParas = StructureSelect(' Varname ];
    if nargin>=3
        for i = 1:2:length(varargin)
            if iscell(varargin{i+1})
                EvalStr = [EvalStr ',' '''' varargin{i} ''',{' ];
                for j=1:length(varargin{i+1})
                EvalStr = [EvalStr  '''' varargin{i+1}{j} ''',' ];
                end
                EvalStr(end) = '}';
            else
            EvalStr = [EvalStr ',' '''' varargin{i} ''','''  varargin{i+1} ''''];
            end
        end
    end
    EvalStr = [EvalStr ');'];
    end

