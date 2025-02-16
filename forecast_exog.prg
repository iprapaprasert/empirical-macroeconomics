' Empirical Macroeconomics Part II: Macroeconomic Model
' Module 2: Forecasting Exogenous Variables

include linipolate
include eqipolate
include consipolate

' note that to get last date in range, use @otod(@obsrange)
' to get last date containing actual value, use @otod(@ilast(_))

' Consumer Price Index
call linipolate("pcpi", @otod(@ilast(pcpi) + 4), 4.0)
call linipolate("pcpi", @otod(@obsrange), 4.0)	
		
series cpi = @recode(@isna(cpi), cpi(-4) * (1+pcpi / 100), cpi)

' Exchange Rate (TH USD)							
call linipolate("thbusd", @otod(@ilast(thbusd) + 4), 32.00)
call linipolate("thbusd", @otod(@ilast(thbusd) + 4), 30.00)
call linipolate("thbusd", @otod(@obsrange), 29.00)	

' Brent Oil Price	
call linipolate("brent", @otod(@ilast(brent) + 4), 73)
call linipolate("brent", @otod(@ilast(brent) + 4), 75)
call linipolate("brent", @otod(@obsrange), 78)

' US GDP					
call consipolate("pusgdp", @otod(@ilast(pusgdp) + 1), 2.60)				
call consipolate("pusgdp", @otod(@ilast(pusgdp) + 1), 2.70)				
call consipolate("pusgdp", @otod(@ilast(pusgdp) + 1), 2.85)								
call consipolate("pusgdp", @otod(@obsrange), 2.70)						

series usgdp = @recode(@isna(usgdp), usgdp(-4) * (1+pusgdp / 100), usgdp)
series iusgdp = usgdp / @elem(usgdp, 2005q1)

' China GDP
call consipolate("pchgdp", @otod(@ilast(pchgdp) + 1), 6.0)	
call consipolate("pchgdp", @otod(@ilast(pchgdp) + 1), 6.5)	
call consipolate("pchgdp", @otod(@ilast(pchgdp) + 1), 7.0)	
call consipolate("pchgdp", @otod(@ilast(pchgdp)+ 1), 7.5)
call linipolate("pchgdp", @otod(@ilast(pchgdp) + 4), 9)	
call linipolate("pchgdp", @otod(@obsrange), 9.5)

series chgdp = @recode(@isna(chgdp), pchgdp + 100, chgdp)
series ichgdp = chgdp / @elem(chgdp, 2005q1)

' EU GDP
call consipolate("peugdp", @otod(@ilast(pchgdp) + 1), 1.81)	
call consipolate("peugdp", @otod(@ilast(pchgdp) + 1), 1.74)	
call consipolate("peugdp", @otod(@ilast(pchgdp) + 1), 1.83)	
call consipolate("peugdp", @otod(@ilast(pchgdp) + 1), 1.40)	
call consipolate("peugdp", @otod(@ilast(pchgdp) + 1), 1.55)	
call consipolate("peugdp", @otod(@ilast(pchgdp) + 1), 1.70)
call consipolate("peugdp", @otod(@ilast(pchgdp) + 1), 1.85)	
call consipolate("peugdp", @otod(@obsrange), 1.90)	

series eugdp = @recode(@isna(eugdp), eugdp(-4) * (1+peugdp / 100), eugdp)
series ieugdp = eugdp / @elem(eugdp, 2005q1)

'Japan GDP
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), -0.80)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 0.30)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.50)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.90)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 0.90)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.00)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.10)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.40)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.70)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.60)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.60)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.45)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.30)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.15)	
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.00)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.00)		
call consipolate("pjpgdp", @otod(@ilast(pjpgdp) + 1), 1.00)		
call consipolate("pjpgdp", @otod(@obsrange), 1.00)
		
series jpgdp = @recode(@isna(jpgdp), jpgdp(-4) * (1+pjpgdp / 100), jpgdp)
series ijpgdp = jpgdp / @elem(jpgdp, 2005q1)

series g4index = (0.364916917*ieugdp) + (0.341400814*iusgdp) + (0.189467304*ichgdp) + (0.104214964*ijpgdp)
series pg4index = @pcy(g4index)

'SD is purely ARMA
call eqipolate("sd", "2011q2", "sar(4) ma(1)", "2000q1 @last")

' Number of tourist visitors
call eqipolate("visit", "2011q2", "sar(4) ma(1) @isperiod(""2003q2"") @isperiod(""2006q1"")", "@all")


