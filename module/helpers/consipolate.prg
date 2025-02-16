subroutine consipolate(string %series, string %to, scalar !value)
    %from = @otod(@ilast({%series}) + 1) ' first na
    %period = %from + " " + %to
    series {%series} = @recode(@during(%period), !value, {%series})
endsub
