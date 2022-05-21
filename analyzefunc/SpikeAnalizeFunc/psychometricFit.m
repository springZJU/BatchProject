function [R2,yFit,fitRes,Threshold,norx] = psychometricFit(be,plotYN,defopt,varargin)
x = [1, 1.1, 1.21, 1.33, 1.46]';
sampleRate = 50;
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(defopt) '=ReadStructValue(defopt);']);

if plotYN
    figure
end

if size(be,2) > 1
    hh = waitbar(0,'please wait');
end
for i=1:size(be,2)
    if size(be,2) > 1
        str=['Fitting, current: ' num2str(i) , '(' num2str(i) '/' num2str(size(be,2)) ')' ];
        waitbar(i/size(be,2),hh,str);
    end
    if exist('lanmuda','var')
        x = lanmuda(:,i);
    end
    y = be(:,i);
    method = defopt.fitMethod;
    if ~iscell(method) & ischar(method)
        method = cellstr(method);
    end
    for methodN = 1:length(method)
        switch method{methodN}
%% sigmoid
            case 'sigmoid'
                try
                    % Define Start points, fit-function and fit curve
                    x0 = [1 0];
                    fitfun = fittype( @(a,b,x) 1./(1+exp(-a*x-b)));
                    [fitresult,gof] = fit(x,y,fitfun,'StartPoint',x0);
                    xFit = x(1):(x(end)-x(1))/sampleRate:x(end);
                    yFit(i).(method{methodN}) = 1./(1+exp(-fitresult.a*xFit-fitresult.b));
                    fitLoop = 0;
                    while (yFit(i).(method{methodN})(1)>0.2 | yFit(i).(method{methodN})(1) <0 | yFit(i).(method{methodN})(5)<0.8) & fitLoop<20
                        try
                            fitLoop = fitLoop + 1;
                            [fitresult,gof] = fit(x,y,fitfun,'StartPoint',x0);
                            yFit(i).(method{methodN}) = 1./(1+exp(-fitresult.a*xFit-fitresult.b));
                        catch
                            continue
                        end
                    end
                    fitRes(i).(method{methodN}) = fitresult;
                    norx(i).(method{methodN}) = x;

                    %计算阈值
                    syms x1
                    eqn = 1./(1+exp(-fitresult.a*x1-fitresult.b)) == 0.8;
                    solx = solve(eqn,x1);
                    solx = abs(double(solx));
                    Threshold(i).(method{methodN}) = min(unique(solx(solx>0&solx<xThr)));
                    if isempty(Threshold(i).(method{methodN}))
                        Threshold(i).(method{methodN}) = xThr;
                    elseif Threshold(i).(method{methodN}) > xThr
                        Threshold(i).(method{methodN}) = xThr;
                    end
                    fitSuccsess = true;
                    %plot（yes/no）
                    if plotYN
                        subplot(2,2,1)
                        h = plot( fitresult, x, y );hold on;
                        legend('off')

                        % Label axes
                        xlabel( 'x', 'Interpreter', 'none' );
                        ylabel( 'y', 'Interpreter', 'none' );
                        title('sigmoid')
                    end
                    R2(i).(method{methodN})=gof.rsquare;
                catch
                    R2(i).(method{methodN})=-1;
                    Threshold(i).(method{methodN}) = xThr;
                end
%% logistic
            case 'logistic'
                try

                    [xData, yData] = prepareCurveData( x, y );
                    xFit = x(1):(x(end)-x(1))/sampleRate:x(end);
                    ft = fittype( '1-1./(1+(x/a)^b)', 'independent', 'x', 'dependent', 'y' );
                    [fitresult, gof] = fit( xData, yData, ft );
                    yFit(i).(method{methodN})  = 1-1./(1+(xFit/fitresult.a).^fitresult.b);
                    fitLoop = 0;
                    while (yFit(i).(method{methodN})(1)>0.2 | yFit(i).(method{methodN})(1) <0 | yFit(i).(method{methodN})(5)<0.8) & fitLoop<20
                        try
                            fitLoop = fitLoop + 1;
                            [fitresult, gof] = fit( xData, yData, ft);
                            yFit(i).(method{methodN}) = 1-1./(1+(xFit/fitresult.a).^fitresult.b);
                        catch
                            continue
                        end
                    end
                    fitRes(i).(method{methodN}) = fitresult;
                    norx(i).(method{methodN}) = x;

                    %计算阈值
                    syms x1
                    eqn = 1-1./(1+(x1/fitresult.a).^fitresult.b) == 0.8;
                    solx = solve(eqn,x1);
                    solx = abs(double(solx));
                    Threshold(i).(method{methodN}) = min(unique(solx(solx>0&solx<xThr)));
                    if isempty(Threshold(i).(method{methodN}))
                        Threshold(i).(method{methodN}) = xThr;
                    elseif Threshold(i).(method{methodN}) > xThr
                        Threshold(i).(method{methodN}) = xThr;
                    end

                    %plot（yes/no）
                    if plotYN
                        % Plot fit with data.
                        subplot(2,2,2)
                        h = plot( fitresult, xData, yData );hold on;
                        legend('off')

                        % Label axes
                        xlabel( 'x', 'Interpreter', 'none' );
                        ylabel( 'y', 'Interpreter', 'none' );
                        title('logistic')
                    end
                    R2(i).(method{methodN})=gof.rsquare;
                catch
                    R2(i).(method{methodN})=-1;
                    Threshold(i).(method{methodN}) = xThr;
                end
            case 'weibull'
%% weibull
                try

                    [xData, yData] = prepareCurveData( x, y );
                    xFit = x(1):(x(end)-x(1))/sampleRate:x(end);
                    ft = fittype( '1-exp(-(x/a)^b)', 'independent', 'x', 'dependent', 'y' );
                    [fitresult, gof] = fit( xData, yData, ft );
                    yFit(i).(method{methodN}) = 1-exp(-(xFit/fitresult.a).^fitresult.b);
                    fitLoop = 0;
                    while (yFit(i).(method{methodN})(1)>0.2 | yFit(i).(method{methodN})(1) <0 | yFit(i).(method{methodN})(5)<0.8) & fitLoop<20
                        try
                            fitLoop = fitLoop + 1;
                            [fitresult, gof] = fit( xData, yData, ft);
                            yFit(i).(method{methodN}) = 1-exp(-(xFit/fitresult.a).^fitresult.b);
                        catch
                            continue
                        end
                    end
                    fitRes(i).(method{methodN}) = fitresult;
                    norx(i).(method{methodN}) = x;

                     %计算阈值
                    syms x1
                    eqn = 1-exp(-(x1/fitresult.a).^fitresult.b) == 0.8;
                    solx = solve(eqn,x1);
                    solx = abs(double(solx));
                    Threshold(i).(method{methodN}) = min(unique(solx(solx>0&solx<xThr)));
                    if isempty(Threshold(i).(method{methodN}))
                        Threshold(i).(method{methodN}) = xThr;
                    elseif Threshold(i).(method{methodN}) > xThr
                        Threshold(i).(method{methodN}) = xThr;
                    end

                    %plot（yes/no）
                    if plotYN
                        % Plot fit with data.
                        subplot(2,2,3)
                        h = plot( fitresult, xData, yData );hold on;
                        legend('off')

                        % Label axes
                        xlabel( 'x', 'Interpreter', 'none' );
                        ylabel( 'y', 'Interpreter', 'none' );
                        title('webull')
                    end
                    R2(i).(method{methodN})=gof.rsquare;
                catch
                    R2(i).(method{methodN})=-1;
                    Threshold(i).(method{methodN}) = xThr;
                end
%% gaussint
            case 'gaussint'
                try

                    [xData, yData] = prepareCurveData( x, y );
                    ft = fittype( 'erf(c*x-b/(sqrt(2)*a))', 'independent', 'x', 'dependent', 'y' );
                    
                    xFit = x(1):(x(end)-x(1))/sampleRate:x(end);
                    try
                        [fitresult, gof] = fit( xData, yData, ft);
                        yFit(i).(method{methodN}) = erf(fitresult.c*xFit-fitresult.b/(sqrt(2)*fitresult.a));
                    catch
                        fitresult = [];
                        yFit(i).(method{methodN}) = zeros(1,sampleRate+1);
                    end
                    fitLoop = 0;
                    while (yFit(i).(method{methodN})(1) <0 | yFit(i).(method{methodN})(5)<0.8) & fitLoop<5
                        try
                            fitLoop = fitLoop + 1;
                            [fitresult, gof] = fit( xData, yData, ft);
                            yFit(i).(method{methodN}) = erf(fitresult.c*xFit-fitresult.b/(sqrt(2)*fitresult.a));
                        catch
                            continue
                        end
                    end
                    fitRes(i).(method{methodN}) = fitresult;
                    norx(i).(method{methodN}) = x;

                     %计算阈值
                    syms x1
                    eqn = erf(fitresult.c*x1-fitresult.b/(sqrt(2)*fitresult.a)) == 0.8;
                    solx = solve(eqn,x1);
                    solx = abs(double(solx));
                    Threshold(i).(method{methodN}) = min(unique(solx(solx>0&solx<xThr)));
                    if isempty(Threshold(i).(method{methodN}))
                        Threshold(i).(method{methodN}) = xThr;
                    elseif Threshold(i).(method{methodN}) > xThr
                        Threshold(i).(method{methodN}) = xThr;
                    end

                    %plot（yes/no）
                    if plotYN
                        subplot(2,2,4)
                        h = plot( fitresult, xData, yData );hold on;
                    
                    legend('off')
                    % Label axes
                    xlabel( 'x', 'Interpreter', 'none' );
                    ylabel( 'y', 'Interpreter', 'none' );
                    ylim([0 1]);
                    title('gaussint')
                    end
                    R2(i).(method{methodN})=gof.rsquare;
                catch
                    R2(i).(method{methodN})=-1;
                    
                    norx(i).(method{methodN}) = x;
                    Threshold(i).(method{methodN}) = xThr;
                end
        end
    end
end
if size(be,2) > 1
    delete(hh);
end
% figure
% for i=1:4
% subplot(2,2,i)
% nbins=0:0.2:2;
% histogram(R2{i},nbins)
% title(num2str(mean(R2{i}(find(R2{i}(:)>0),1))))
% end
