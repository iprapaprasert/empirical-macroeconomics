' Empirical Macroeconomics Part II: Macroeconomic Model
' Module 3: Equation

' PCE
equation eqpce.ls pce c ar(1) @movav(gdp(-1),4) @seas(2) @seas(3) @seas(4) @isperiod("2009q1") @isperiod("2009q2") @isperiod("2009q3") @isperiod("2011q1") 	

' GCE
equation eqgce.ls gce c @seas(2) @seas(3) @seas(4) @trend @isperiod("2009q1")

' PRICAP
equation eqpricap.ls pricap c @movav(gdp,2) stockpri(-1) @seas(2) @seas(3) @seas(4) @isperiod("2007q4") @isperiod("2008q1") @isperiod("2008q2") @isperiod("2008q3") 	

' PUBCAP
equation eqpubcap.ls pubcap c replacepub @seas(2) @seas(3) @seas(4)

' INV
equation eqinv.ls inv @seas(1) @seas(2) @seas(3) @seas(4) d(img) d(img(-1)) d(gsales) pg4index ma(1)

' EXG
equation eqexg.ls exg c usgdp eugdp jpgdp d(thbusd) @trend @seas(2) @seas(3) @seas(4) 

' EXS
equation eqexs.ls exs c visit @movav(visit,4) g4index @trend @seas(2) @seas(3) @seas(4) ma(4)

' IMG
equation eqimg.ls img c fsales fsales(-1 to -4) @isperiod("2005q1") @isperiod("2005q2") @seas(2) @seas(3) @seas(4)

' IMS
equation eqims.ls ims c @movav(fsales,4) @movav(thbusd,2) @seas(2) @seas(3) @seas(4) @trend @isperiod("2002q2") @isperiod("2003q4") @isperiod("2005q1")

' GDPDEF
equation eqgdpdef.ls gdpdef c pcedef imgdef @seas(2) @seas(3) @seas(4) sar(1) sma(1)

' PCEDEF
equation eqpcedef.ls pcedef c cpi @seas(2) @seas(3) @seas(4) 

' GCEDEF
equation eqgcedef.ls gcedef c cpi @seas(2) @seas(3) @seas(4) @trend gdpdef sar(4)

' PRICAPDEF
equation eqpricapdef.ls pricapdef c @movav(brent,2) @movav(imgdef,2) @seas(2) @seas(3) @seas(4) @trend

' PUBCAPDEF
equation eqpubcapdef.ls pubcapdef c @movav(brent,2) @movav(imgdef,4) @seas(2) @seas(3) @seas(4) @trend sar(1)

' EXGDEF
equation eqexgdef.ls exgdef c ar(1) @movav(brent,4) @movav(usgdp,2) thbusd cpi

' EXSDEF
equation eqexsdef.ls exsdef c cpi

' IMGDEF
equation eqimgdef.ls imgdef c ar(1) @movav(brent,2) thbusd

' IMSDEF
equation eqimsdef.ls imsdef c ar(1) @movav(brent,2) @seas(2) @seas(3) @seas(4) @trend

' BM
equation eqbm.ls bm c @trend gdp cpi ar(1) ma(1)


