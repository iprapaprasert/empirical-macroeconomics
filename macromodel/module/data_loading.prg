' Empirical Macroeconomics Part II: Macroeconomic Model
' Module 1: Data Loading
include .\helpers\linkmtoq

' Load data
'' Convention: _x = nominal, _ = real
import(wf=macromodel, page=q) .\data\quarterly.xlsx range="My Series!$a$195" names=("date", "gdpx",  "pcex", "gcex", "pricapx", "pubcapx", "exgx", "exsx", "imgx", "imsx", "gdp", "pce", "gce", "gfcf", "pricap", "pubcap", "inv", "ex", "exg", "exs", "im", "img", "ims", "sd", "chgdp", "eugdp", "jpgdp", "usgdp") @freq q @id @date(date) ' MANUAL SET

import(wf=macromodel, page=m) .\data\monthly.xlsx range="My Series!$a$11" names=("date", "cpi", "thbusd", "brent", "visit", "bm") @freq m @id @date(date) ' MANUAL SET

' Convert monthly data to quarterly data
pageselect q
call linkmtoq("cpi", "a")
call linkmtoq("thbusd", "a")
call linkmtoq("brent", "a")
call linkmtoq("visit", "ns")
call linkmtoq("bm", "a")

' Generate stock and replacement
'' Overall stock
series stock = @recode(@trend = 0, gfcf / 0.053, (1 - 0.053) * stock(-1) + gfcf)
series replace = 0.053 * stock

'' Private Investment
series stockpri = @recode(@trend = 0, pricap / 0.053, (1 - 0.053) * stockpri(-1) + pricap)
series replacepri = 0.053 * stockpri

'' Public Investment
series stockpub = @recode(@trend = 0, pubcap / 0.053, (1 - 0.053) * stockpub(-1) + pubcap)
series replacepub = 0.053 * stockpub

' Generate aggregated series
series fsales = pce + gce + gfcf + exg + exs
series gsales = pce + gce + gfcf + exg
series gfcfx = pricapx + pubcapx
series exx = exgx + exsx
series imx = imgx + imsx

' Generate deflator
series gdpdef = 100 * gdpx / gdp				
series pcedef = 100 * pcex / pce
series gcedef = 100 * gcex / gce
series gfcfdef = 100 * gfcfx / gfcf
series pricapdef = 100 * pricapx / pricap	
series pubcapdef = 100 * pubcapx / pubcap	
series exdef  = 100 * exx / ex
series exgdef = 100 * exgx / exg
series exsdef = 100 * exsx / exs
series imdef  = 100 * imx / im
series imgdef = 100 * imgx / img
series imsdef = 100 * imsx / ims

' Generate annually percentage change
series pcpi = @pcy(cpi)
series pusgdp = @pcy(usgdp)
series pchgdp = chgdp - 100 ' Chinese GDP is in the index form
series peugdp = @pcy(eugdp)
series pjpgdp = @pcy(jpgdp)


' Generate composite index of foreign economies, 2005q1=100
series iusgdp = usgdp / @elem(usgdp, 2005q1)
series ieugdp = eugdp / @elem(eugdp, 2005q1)
series ijpgdp = jpgdp / @elem(jpgdp, 2005q1)
series ichgdp = chgdp / @elem(chgdp, 2005q1)
series g4index = (0.364916917 * ieugdp) + (0.341400814 * iusgdp) + (0.189467304 * ichgdp) + (0.104214964 * ijpgdp) 'Weighted share calculated from IMF (2008), PPP
series pg4index = @pcy(g4index)

' Extending range to 3 years ahead
pagestruct(end=@last+12)

