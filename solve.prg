' Empirical Macroeconomics Part II: Macroeconomic Model
' Module 5: Solving a Model

include addshift

' First forecasting date should be 2 yrs prior the latest actual date
%fstart = @otod(@ilast(gdp) - 8)

' Baseline
smpl %fstart @last
mm.solve
smpl @all

' Add factor
mm.addassign(v) gce exg exs img ims pce exgdef exsdef imgdef imsdef gdpdef pcedef gcedef bm pricap pubcap pricapdef pubcapdef stockpri inv

'' Shift date
'' We pick the date contains the latest actual data
%shiftdate = @otod(@ilast(gdp))

'' Shift
call addshift("exg", %shiftdate)
call addshift("img", %shiftdate)
call addshift("exs", %shiftdate)
call addshift("imgdef", %shiftdate)
call addshift("imsdef", %shiftdate)
call addshift("exgdef", %shiftdate)
call addshift("pce", %shiftdate)

smpl %fstart @last
mm.solve
smpl @all


