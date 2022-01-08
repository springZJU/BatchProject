function varargout=AverageDiffLength(data,varargin)
DataRow=size(data,1);
DataCol=size(data,2);
try meandir=varargin{1};
    if meandir==1 %average by row
        for DRnum=1:DataRow
            for DCnum=1:DataCol
                buffer=data{DRnum,DCnum};
                BufferRow=size(buffer,1);
                BufferCol=size(buffer,2);
                for BRnum=1:BufferRow
                    for BCnum=1:BufferCol
                        try SampleBuffer.raw{DRnum}{BRnum,BCnum};
                            SampleBuffer.raw{DRnum}{BRnum,BCnum}=[SampleBuffer.raw{DRnum}{BRnum,BCnum}; buffer(BRnum,BCnum)];
                        catch
                            SampleBuffer.raw{DRnum}{BRnum,BCnum}=buffer(BRnum,BCnum);
                        end
                    end
                end
            end
        end
        for DRnum=1:DataRow
            for BRnum=1:BufferRow
                for BCnum=1:BufferCol
                    try
                        SampleBuffer.mean{DRnum,1}(BRnum,BCnum)=mean(SampleBuffer.raw{DRnum}{BRnum,BCnum});
                    catch
                    end
                end
            end
        end
    else%average by column
        for DRnum=1:DataRow
            for DCnum=1:DataCol
                buffer=data{DRnum,DCnum};
                BufferRow=size(buffer,1);
                BufferCol=size(buffer,2);
                for BRnum=1:BufferRow
                    for BCnum=1:BufferCol
                        try SampleBuffer.raw{DCnum}{BRnum,BCnum};
                            SampleBuffer.raw{DCnum}{BRnum,BCnum}=[SampleBuffer.raw{DCnum}{BRnum,BCnum}; buffer(BRnum,BCnum)];
                        catch
                            SampleBuffer.raw{DCnum}{BRnum,BCnum}=buffer(BRnum,BCnum);
                        end
                    end
                end
            end
        end
        for DCnum=1:DataCol
            for BRnum=1:BufferRow
                for BCnum=1:BufferCol
                    try
                        SampleBuffer.mean{1,DCnum}(BRnum,BCnum)=mean(SampleBuffer.raw{DCnum}{BRnum,BCnum});
                    catch
                    end
                end
            end
        end
    end
catch
    for DRnum=1:DataRow
        for DCnum=1:DataCol
            buffer=data{DRnum,DCnum};
            BufferRow=size(buffer,1);
            BufferCol=size(buffer,2);
            for BRnum=1:BufferRow
                for BCnum=1:BufferCol
                    try SampleBuffer.raw{BRnum,BCnum};
                        SampleBuffer.raw{BRnum,BCnum}=[SampleBuffer.raw{BRnum,BCnum}; buffer(BRnum,BCnum)];
                    catch
                        SampleBuffer.raw{BRnum,BCnum}=buffer(BRnum,BCnum);
                    end
                end
            end
        end
    end

    for BRnum=1:BufferRow
        for BCnum=1:BufferCol
            try
                SampleBuffer.mean(BRnum,BCnum)=mean(SampleBuffer.raw{BRnum,BCnum});
            catch
            end
        end
    end

end
varargout{1}=SampleBuffer.mean;
varargout{2}=SampleBuffer.raw;




