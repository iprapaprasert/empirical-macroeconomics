subroutine eqipolate(string %series, string %fstart, string %eq, string %smpl)
    smpl {%smpl}
    equation ipolate{%series}.ls {%series} {%eq}
    smpl {%fstart}+1 @last
    ipolate{%series}.forecast(e) tempf
    series {%series} = tempf
    smpl @all
    delete tempf*
endsub


