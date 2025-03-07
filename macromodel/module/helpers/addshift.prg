subroutine addshift(String %var, String %period)
    !temp = @elem({%var}, %period) - @elem({%var}_0, %period)
    series {%var}_a = @recode(@after(%period), !temp, na)
endsub


