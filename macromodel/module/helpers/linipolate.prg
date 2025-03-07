subroutine linipolate(string %series, string %to, scalar !value)
    %from = @otod(@ilast({%series}))
    series {%series} = @recode(@isperiod(%to), !value, {%series})
    smpl {%from} {%to}
    {%series}.ipolate ipo{%series}
    series {%series} = ipo{%series}
    smpl @all
    delete ipo{%series}
endsub


