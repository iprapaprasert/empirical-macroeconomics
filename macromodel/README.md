# Empirical Macroeconomics Part II: Macroeconomic Model
In this note, we will introduce the simple macroeconomic model. We model the Thai macroeconomy in EViews consisting 5 modules:

1. Data Loading
2. Forecasting Exogenous Variables
3. Forecasting Endogenous Variables Using equations
4. Model Linkage
5. Solving Model

We execute all of these modules by writing `main` module. You only need to execute this program to gain insights and forecast Thai macroeconomy.

```
' Main Module
cd d:\empirical-macroeconomics
exec .\data_loading
exec .\forecast_exog
exec .\equation
exec .\model
exec .\solve
```

In the following section, we focus on each step in order, ranging from data loading, forecast exogenous variables, forecast endogenous variables, model linkage, and solving model.

## A Glipse at the EViews Command
Before we drive into modelling part. We take a note of some rare commands in EViews.

| command        | function |
| -------        | -------- |
| `@movav(x, n)` | n-period backward moving average |
| `@seas(x)`     | seasonal dummy | 
| `@isperiod()`  | |
| `@trend` | |
| `@elem` | |
| `@obssmpl` | |
| `@recode` | |
| `@otod` | |
| `@ilast()` | |
| `@obsrange` | |

## Data Loading
In this section, we will delve into the first module, data loading.

Before we load data into EViews program, we have to build the data file in Excel. We recommend using CEIC program for real-time and convenient managing and updating data.  

The list of macroeconomic data are provided here, we separate into two frequencies: monthly and quarterly data:

### Monthly
| Name                      | CEIC Series Code   | Variable Name |  
| ----                      | ----------------   | ------------- |
| Consumer Price Index               | 541395757(TIYZDAAAAAAFHU) | `cpi` |
| Forex: Thai Baht to US Dollar: Mid | 39243101(TMDAB) | `thbusd` |
| Brent Crude Oil Price              | 103001807 | `brent` |
| Number of International Tourists   |  382997307(TQVCBAPBLAAIIJ) | `visit` |
| Monetary Aggregates (MA): Broad Money | 135762001(TKAAAAAA) | `bm` |

### Quarterly
| Name | Variable Name |
| ---- | ------------- |
| Gross Domestic Product: 2002p: Chain Volume Measures (CVM) | `gdp` |
| GDP: 2002p: CVM: Consumption Expenditure: Private | `pce` |
| GDP: 2002p: CVM: Consumption Expenditure: Government | `gce` |
| GDP: 2002p: CVM: Gross Fixed Capital Formation | `gfcf` |
| GDP: 2002p: CVM: GFCF: Private | `pricap` |
| GDP: 2002p: CVM: GFCF: Public | `pubcap` |
| GDP: 2002p: CVM: Exports of Goods and Services | `ex` |
| GDP: 2002p: CVM: Exports of Goods and Services: Goods | `exg` |
| GDP: 2002p: CVM: Exports of Goods and Services: Services | `exs` |
| GDP: 2002p: CVM: Imports of Goods and Services | `im` |
| GDP: 2002p: CVM: Imports of Goods and Services: Goods | `img` |
| GDP: 2002p: CVM: Imports of Goods and Services: Services | `ims` |
| GDP: 2002p: CVM: Change In Inventories | `inv` |
| GDP: 2002p: CVM: Residual | `sd` |
| Gross Domestic Product | `gdpx` |
| GDP: Consumption Expenditure: Private | `pcex` |
| GDP: Consumption Expenditure: Government `gcex` |
| GDP: Gross Fixed Capital Formation: Private | `pricapx` |
| GDP: Gross Fixed Capital Formation: Public |`pubcapx` |
| GDP: Exports of Goods and Services: Goods |`exgx` |
| GDP: Exports of Goods and Services: Services |`exsx` |
| GDP: Imports of Goods and Services: Goods |`imgx` |
| GDP: Imports of Goods and Services: Services | `imsx` |
| Gross Domestic Product: 2017p: saar (United States) | `usgdp` |
| GDP: CL 2020p: EU27 excl UK (EU 27E) (European Union) | `eugdp` |
| Gross Domestic Product: 2015 Market Price (2015p) (Japan) | `jpgdp` |
| GDP Index: PY=100 | `chgdp` |

### Load Data
Use the following command to load these data to EViews. Note that we use data since 1993Q1 because this is the first period that GDP was released.
```
' Load data
'' Convention: _x = nominal, _ = real
import(wf=macromodel, page=q) quarterly.xlsx range="My Series!$a$195" names=("date", "gdpx",  "pcex", "gcex", "pricapx", "pubcapx", "exgx", "exsx", "imgx", "imsx", "gdp", "pce", "gce", "gfcf", "pricap", "pubcap", "inv", "ex", "exg", "exs", "im", "img", "ims", "sd", "chgdp", "eugdp", "jpgdp", "usgdp") @freq q @id @date(date) ' MANUAL SET

import(wf=macromodel, page=m) monthly.xlsx range="My Series!$a$11" names=("date", "cpi", "thbusd", "brent", "visit", "bm") @freq m @id @date(date) ' MANUAL SET
```

### Link Monthly Data to Quarterly Data
Since we want to work in quarterly basis, given the nature of GDP that is released in quarterly frequency. We write a subroutine to link monthly data into quarterly data

```
subroutine linkmtoq(String %series, String %convert)
	'''
	' High to low frequency conversion (m -> q)
	' usually %convert should be:
	' - "a" (average of the nonmissing observation)
	' - "ns" (sum, propagating missing)
	'''
	copy(c={%convert}) m\{%series} q\
endsub

```
Then, we convert these monthly data into a quarterly data
```
' Convert monthly data to quarterly data
pageselect q
call linkmtoq("cpi", "a")
call linkmtoq("thbusd", "a")
call linkmtoq("brent", "a")
call linkmtoq("visit", "ns")
call linkmtoq("bm", "a")
```
Next, we generate stock and replacement. We initialize the stock value equal to `gfcf` divided by 0.053 on the first date (1993Q1). Note that we use `@trend = 0` to specify the first date programmatically. Similarly, we initialize the private stock value equal to `pricap` and the public stock equal to `pubcap` by the same fashion.

Subsequent stock is defined by 0.947 (= 1 - 0.053) of previous capital stock plus new captial. Hence, the replacement is equal to 0.053 of the new capital.

```
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
```

### Calculated Series
We generate five calculated series: Total good demand, Total good and service demand, Nominal gross fixed capital formation, Nominal export, and Nominal import.

```
series fsales = pce + gce + gfcf + exg + exs
series gsales = pce + gce + gfcf + exg
series gfcfx = pricapx + pubcapx
series exx = exgx + exsx
series imx = imgx + imsx
```

Prices and deflators are determined by the following series
```
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
```

We also defined growth rate for several variables
```
series pcpi = @pcy(cpi)
series pusgdp = @pcy(usgdp)
series pchgdp = chgdp - 100 ' Chinese GDP is in the index form
series peugdp = @pcy(eugdp)
series pjpgdp = @pcy(jpgdp)
```

Lastly, we defined the index of foreign economy GDP. The base reference is at 2005Q1. We also defined the composite index of 4 countries called `g4index` and its annually percentage change.

```
' Generate composite index of foreign economies, 2005q1=100
series iusgdp = usgdp / @elem(usgdp, 2005q1)
series ieugdp = eugdp / @elem(eugdp, 2005q1)
series ijpgdp = jpgdp / @elem(jpgdp, 2005q1)
series ichgdp = chgdp / @elem(chgdp, 2005q1)
series g4index = (0.364916917 * ieugdp) + (0.341400814 * iusgdp) + (0.189467304 * ichgdp) + (0.104214964 * ijpgdp) 'Weighted share calculated from IMF (2008), PPP
series pg4index = @pcy(g4index)
```

Finally, we extending range to 3 years ahead for supporting out-of-sample forecast.
```
pagestruct(end=@last+12)
```

## Forecasting Exogenous Variables
In this section, we will delve into the second module, forecasting exogenous variables.

There are some EViews techniques to get the specific dates. We will look at these first:

1. To get the last date in range, we use `@otod(@obsrange)`
2. to get last date containing actual value, we use `@otod(@ilast(_))`, where `_` is series.

### Forecasting Technique
There are 3 techniques to forecast exogenous variables
#### Constant Interpolation
This type of forecasting use the same value for the whole selected period. For instance, the GDP growth of foreign countries should use this type of forecasting as the value of variables do not change much due to the nature of the economists' consensus forecasts.

```
subroutine consipolate(string %series, string %to, scalar !value)
	%from = @otod(@ilast({%series}) + 1) ' first na
	%period = %from + " " + %to
	series {%series} = @recode(@during(%period), !value, {%series})
endsub
```
#### Linear Interpolation
This type of forecasting set the value for the end period. Then, using the linear interpolation technique to fill in intermediate values from the latest period with actual value (start period) to the end period. This technique proves useful for most series. For instance, the consumer price index, and the oil price use this technique since we get the target value based on expert judgement or economists' consensus.
```
subroutine linipolate(string %series, string %to, scalar !value)
	%from = @otod(@ilast({%series}))
	series {%series} = @recode(@isperiod(%to), !value, {%series})
	smpl {%from} {%to}
	{%series}.ipolate ipo{%series}
	series {%series} = ipo{%series}
	smpl @all
	delete ipo{%series}
endsub
```

#### Equation Interpolation
This type of interpolation imputes the forecasted value of the specified econometric model to the series. Any high-volatile economic variables, such a the number of international tourists and statistical discrepancy, should use this type of interpolation.
```
subroutine eqipolate(string %series, string %fstart, string %eq, string %smpl)
	smpl {%smpl}
	equation ipolate{%series}.ls {%series} {%eq}
	smpl {%fstart}+1 @last
	ipolate{%series}.forecast(e) tempf
	series {%series} = tempf
	smpl @all
	delete tempf*
endsub
```
### Forecasting Exogenous Variables

#### Consumer Price Index (CPI)
We use linear interpolation technique to forecast the percentage change of CPI (inflation). Then, we update the level of CPI.
```
call linipolate("pcpi", @otod(@ilast(pcpi) + 4), 4.0)
call linipolate("pcpi", @otod(@obsrange), 4.0)	
		
series cpi = @recode(@isna(cpi), cpi(-4) * (1+pcpi / 100), cpi)	
```

#### Exchange Rate (THB/USD)
We use linear interpolation technique to forecast the exchange rate between THB and USD
```
call linipolate("thbusd", @otod(@ilast(thbusd) + 4), 32.00)
call linipolate("thbusd", @otod(@ilast(thbusd) + 4), 30.00)
call linipolate("thbusd", @otod(@obsrange), 29.00)
```

#### Brent Oil Price
We use linear interpolation technique to forecast the oil price in Brent market
```
call linipolate("brent", @otod(@ilast(brent) + 4), 73)
call linipolate("brent", @otod(@ilast(brent) + 4), 75)
call linipolate("brent", @otod(@obsrange), 78)	
```

#### US GDP
We use constant interpolation technique to forecast the percentage change of the US GDP (`pusgdp`). Data are come from Bloomberg concensus, quarterly forecasting. After that we updated `usgdp` and `iusgdp` respectively.

```
call consipolate("pusgdp", @otod(@ilast(pusgdp) + 1), 2.60)				
call consipolate("pusgdp", @otod(@ilast(pusgdp) + 1), 2.70)				
call consipolate("pusgdp", @otod(@ilast(pusgdp) + 1), 2.85)								
call consipolate("pusgdp", @otod(@obsrange), 2.70)						

series usgdp = @recode(@isna(usgdp), usgdp(-4) * (1+pusgdp / 100), usgdp)
series iusgdp = usgdp / @elem(usgdp, 2005q1)
```

#### China GDP
For China GDP, we use a combination between constant interpolation and linear interpolation.
```
call consipolate("pchgdp", @otod(@ilast(pchgdp) + 1), 6.0)	
call consipolate("pchgdp", @otod(@ilast(pchgdp) + 1), 6.5)	
call consipolate("pchgdp", @otod(@ilast(pchgdp) + 1), 7.0)	
call consipolate("pchgdp", @otod(@ilast(pchgdp)+ 1), 7.5)
call linipolate("pchgdp", @otod(@ilast(pchgdp) + 4), 9)	
call linipolate("pchgdp", @otod(@obsrange), 9.5)

series chgdp = @recode(@isna(chgdp), pchgdp + 100, chgdp)
series ichgdp = chgdp / @elem(chgdp, 2005q1)
```

#### EU GDP
We use constant interpolation technique to forecast the percentage change of the EU GDP (`peugdp`). Data are come from Bloomberg concensus, quarterly forecasting. After that we updated `eugdp` and `ieugdp` respectively.

```
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
```

#### Japan GDP
We use constant interpolation technique to forecast the percentage change of the Japan GDP (`pjpgdp`). Data are come from Bloomberg concensus, quarterly forecasting. After that we updated `jpgdp` and `ijpgdp` respectively.
```
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
```

Next, we update `g4index` and `pg4index`.
```
series g4index = (0.364916917*ieugdp) + (0.341400814*iusgdp) + (0.189467304*ichgdp) + (0.104214964*ijpgdp)
series pg4index = @pcy(g4index)
```

#### Statistical Discrepancy and the Number of Visitors
We update the statistical discrepancy and the number of international tourists by using ARMA equations.

```
'SD
call eqipolate("sd", "2011q2", "sar(4) ma(1)", "2000q1 @last")

'The number of tourist visitors
call eqipolate("visit", "2011q2", "sar(4) ma(1) @isperiod(""2003q2"") @isperiod(""2006q1"")", "@all")
```

## Forecasting Endogenous Variables by Econometric Equation Estimation
In this section, we will delve into the third module, forecasting endogenous variables using econometric equation estimation.

### Private Consumption Expenditure
```
equation eqpce.ls pce c ar(1) @movav(gdp(-1),4) @seas(2) @seas(3) @seas(4) @isperiod("2009q1") @isperiod("2009q2") @isperiod("2009q3") @isperiod("2011q1") 
```

### Government Consumption Expenditure
```
equation eqgce.ls gce c @seas(2) @seas(3) @seas(4) @trend @isperiod("2009q1")
```

### Private Capital Investment
```
equation eqpricap.ls pricap c @movav(gdp,2) stockpri(-1) @seas(2) @seas(3) @seas(4) @isperiod("2007q4") @isperiod("2008q1") @isperiod("2008q2") @isperiod("2008q3")
```

### Public Capital Investment
```
equation eqpubcap.ls pubcap c replacepub @seas(2) @seas(3) @seas(4)
```

### Inventory
```
equation eqinv.ls inv @seas(1) @seas(2) @seas(3) @seas(4) d(img) d(img(-1)) d(gsales) pg4index ma(1)
```

### Export of Goods
```
equation eqexg.ls exg c usgdp eugdp jpgdp d(thbusd) @trend @seas(2) @seas(3) @seas(4)
```

### Export of Services
```
equation eqexs.ls exs c visit @movav(visit,4) g4index @trend @seas(2) @seas(3) @seas(4) ma(4)
```

### Import of Goods
```
equation eqimg.ls img c fsales fsales(-1 to -4) @isperiod("2005q1") @isperiod("2005q2") @seas(2) @seas(3) @seas(4)
```

### Import of Services
```
equation eqims.ls ims c @movav(fsales,4) @movav(thbusd,2) @seas(2) @seas(3) @seas(4) @trend @isperiod("2002q2") @isperiod("2003q4") @isperiod("2005q1")
```

### GDP Deflator
```
equation eqgdpdef.ls gdpdef c pcedef imgdef @seas(2) @seas(3) @seas(4) sar(1) sma(1)
```

### PCE Deflator
```
equation eqpcedef.ls pcedef c cpi @seas(2) @seas(3) @seas(4) 
```

### GCE Deflator
```
equation eqgcedef.ls gcedef c cpi @seas(2) @seas(3) @seas(4) @trend gdpdef sar(4)
```

### Private Investment Deflator
```
equation eqpricapdef.ls pricapdef c @movav(brent,2) @movav(imgdef,2) @seas(2) @seas(3) @seas(4) @trend
```

### Public Investment Deflator
```
equation eqpubcapdef.ls pubcapdef c @movav(brent,2) @movav(imgdef,4) @seas(2) @seas(3) @seas(4) @trend sar(1)
```

### Export Price (Deflator) of Goods
```
equation eqexgdef.ls exgdef c ar(1) @movav(brent,4) @movav(usgdp,2) thbusd cpi
```

### Export Price (Deflator) of Services
```
equation eqexsdef.ls exsdef c cpi
```

### Import Price (Deflator) of Goods
```
equation eqimgdef.ls imgdef c ar(1) @movav(brent,2) thbusd
```

### Import Price (Deflator) of Services
```
equation eqimsdef.ls imsdef c ar(1) @movav(brent,2) @seas(2) @seas(3) @seas(4) @trend
```

### Money Supply
```
equation eqbm.ls bm c @trend gdp cpi ar(1) ma(1)
```

## Model Linkage
In this section, we will delve into the fourth module, model linkage.

We Build a new model called `mm` (macroeconometric model) by using this command
```
model mm
```

Merge the equations into the `mm` model
```
mm.merge eqpce
mm.merge eqgce
mm.merge eqpricap
mm.merge eqpubcap
mm.merge eqinv
mm.merge eqexg
mm.merge eqimg
mm.merge eqexs
mm.merge eqims
mm.merge eqgdpdef
mm.merge eqpcedef
mm.merge eqgcedef
mm.merge eqpricapdef
mm.merge eqpubcapdef
mm.merge eqexgdef
mm.merge eqexsdef
mm.merge eqimgdef
mm.merge eqimsdef
mm.merge eqbm

```
Append identities into the `mm` model
```
mm.append gdp = pce + gce + gfcf + inv + ex - im + sd
mm.append fsales = pce + gce + gfcf + exg + exs
mm.append gsales = pce + gce + gfcf + exg
mm.append gfcf = pricap + pubcap ' Make it simpler
mm.append stock  = (1 - 0.053) * stock(-1)  + gfcf
mm.append replace  = 0.053 * stock
mm.append stockpri = (1 - 0.053) * stockpri(-1)  + pricap
mm.append replacepri = 0.053 * stockpri
mm.append stockpub = (1 - 0.053) * stockpub(-1)  + pubcap
mm.append replacepub = 0.053 * stockpub
mm.append ex  = exg  + exs ' Make it simpler
mm.append im  = img  + ims ' Make it simpler
mm.append gdpx = gdp * gdpdef / 100
mm.append pcex = pce * pcedef / 100
mm.append gcex = gce * gcedef / 100
mm.append pricapx = pricap * pricapdef / 100
mm.append pubcapx = pubcap * pubcapdef / 100
mm.append gfcfx = pricapx + pubcapx
mm.append gfcfdef = 100 * gfcfx / gfcf
mm.append exgx = exg * exgdef / 100
mm.append exsx = exs * exsdef / 100
mm.append exx = exgx + exsx
mm.append exdef = 100 * exx / ex
mm.append imgx = img * imgdef / 100
mm.append imsx = ims * imsdef / 100
mm.append imx = imgx + imsx
mm.append imdef = 100 * imx / im
```

We also append identities that convert the export and import denominated in USD term.
```
'' Denominated in USD
mm.append exgxus = exgx / thbusd
mm.append exsxus = exsx / thbusd
mm.append imgxus = imgx / thbusd
mm.append imsxus = imsx / thbusd
mm.append netserus = exsxus - imsxus
```

Since we are interested in the yearly percentage change of each variable. We also append the yearly percentage change of each variable identity in the `mm` model

```
'' annually percentage change
mm.append pgdp = @pcy(gdp)
mm.append ppce = @pcy(pce)
mm.append pgce = @pcy(gce)
mm.append pgfcf = @pcy(gfcf)
mm.append ppricap = @pcy(pricap)
mm.append ppubcap = @pcy(pubcap)
mm.append pinv = @pcy(inv)
mm.append pex = @pcy(ex)
mm.append pexg = @pcy(exg)
mm.append pexs = @pcy(exs)
mm.append pim = @pcy(im)
mm.append pimg = @pcy(img)
mm.append pims = @pcy(ims)
mm.append pcpi = @pcy(cpi)
mm.append pvisit = @pcy(visit)
```

## Solving a Model
In this section, we will delve into the last module, solving a model.

First of all, we should solving a model at 2 years prior the latest date. We get the first forecasted date by using this command.
```
%fstart = @otod(@ilast(gdp) - 8)
```

Then, we solve the model at baseline
```
' Baseline
smpl %fstart @last
mm.solve
smpl @all
```

To make our forecast more accurate, we use add factor to the following variables
```
mm.addassign(v) gce exg exs img ims pce exgdef exsdef imgdef imsdef gdpdef pcedef gcedef bm pricap pubcap pricapdef pubcapdef stockpri inv
```

To add factor, we have to specify shift value. To simplify thing, we add the shifted value equals to the differenced between actual value and forecasted value at the latest date that contains an actual data.

The subroutine for add shifted value is
```
subroutine addshift(String %var, String %period)
	!temp = @elem({%var}, %period) - @elem({%var}_0, %period)
	series {%var}_a = @recode(@after(%period), !temp, na)
endsub
```

Then, after we add factor (add shifted value). We solve the model again and hope that the accuracy be improved.
```
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
```

