# Macroeconometric Model
The Macroeconometric Model, which models the Thai macroeconomy in EViews, consists of 5 modules:

1. Data Loading
2. Model Linkage

Before moving to other sections, we recommend you to change a directory to `d:\empmacro` by using this command:
```
cd d:\empmacro
```

## Data Loading
Before we load data into EViews program, we have to build the data file in Excel. We recommend using CEIC program for real-time and convenient managing and updating data.  

### Monthly
The list of macroeconomic data are provided here:

| Name                      | CEIC Series Code   | Variable Name | Unit | Frequency | 
| ----                      | ----------------   | ------------- | ---- | --------- |
| Consumer Price Index      | 51806701 (TIBAG)   | `cpi2002` | 2002=100 | Monthly |
| Core Consumer Price Index | 51807601 (TILBABA) | `core2002`|
| Consumer Price Index      | `cpi1998`
| Core Consumer Price Index | `core1998`
| Prime Rate: Minimum Loan Rate (MLR) | `mlr`
| (DC) Repurchase Rate: Month Average: 1 Day | `rp1`
| Forex: Thai Baht to US Dollar: Mid |`thbusd`
| Nominal Effective Exchange Rate Index: Trade weight Broad 21 | `neer`
| Real Effective Exchange Rate Index: Trade weight Broad 21 | `reer`
| PPI: CPA
| Export Price Index (ExPI): USD
| Import Price Index (ImPI): USD
| Export Price Index (EXPI): 2000=100: USD
| Import Price Index (ImPI): 2000=100: USD
| Monetary Aggregates (MA): Broad Money
| (DC) Money Supply M1
| (DC) Money Supply M2
| Labour Productivity Index
| Labour Input Index
| Population: Whole Kingdom
| Unemployment Rate
| Private Consumption Index: Seasonally Adjusted: 10 Indicators
| Consumer Confidence Index
| Consumer Confidence Index: Economics
| Business Sentiment Index: Whole Kingdom
| Brent Crude Oil Price
| Number of International Tourists
| BoP: USD: Exports fob
| BoP: USD: Imports cif
| BoP: USD: Net Services and Transfer
| Imports: Custom Basis: USD
| Exports: Custom Basis: USD

Use the following command to load these data to EViews
```
pagecreate(page="M") m 1980.1 2015.12
read(b68, s=M) THMACRO.xls cpi2002 core2002 cpi1998 core1998 mlr xxxxx rp1 xxxxx	thbusd neer reer ppi xxxxx xxxxx expi2007 impi2007 expi2000	impi2000 bm	xxxxx xxxxx	m1 m2 xxxxx xxxxx xxxxx lpi lii pop unemp pci cci ccie xxxxx xxxxx bsi xxxxx xxxxx xxxxx xxxxx xxxxx xxxxx xxxxx xxxxx xxxxx xxxxx xxxxx xxxxx xxxxx xxxxx brent visit bopexus bopimus boptbus bopnstus custimus custexus
D xxxxx

' read additional monthly data
read(b2,s=AM) THMACRO.xls 99														
D ser*
```


### Calculated Series
We generate the following calculated series

The trade sector is determined by two calculated series
```
genr ex = exg + exs
genr im = img + ims
```

Prices and deflators are determined by the following series
```
genr gdp_def = gdpx / gdp * 100
genr pce_def = pcex / pce * 100
genr gce_def = gcex / gce * 100
genr gfcf_def = gfcfx / gfcf * 100
genr pricap_def = pricapx / pricap * 100
genr pubcap_def = pubcapx / pubcap * 100
genr inv_def = invx / inv * 100
genr sd_def = sdx / sd * 100

genr ex_def = exx / ex * 100
genr exg_def = exgx / exg * 100
genr exs_def = exsx / exs * 100
genr im_def = imx / im * 100
genr img_def = imgx / img * 100
genr ims_def = imsx / ims * 100
```

### Growth Rate
We also defined growth rate for several variables
```
genr p_gdp = @pcy(gdp)
genr p_pce 	= @pcy(pce)
genr p_gce 	= @pcy(gce)
genr p_gfcf	= @pcy(gfcf)
genr p_pricap = @pcy(pricap)
genr p_pubcap = @pcy(pubcap)
genr p_inv 	= @pcy(inv)
genr p_ex 	= @pcy(ex)
genr p_exg 	= @pcy(exg)
genr p_exs 	= @pcy(exs)
genr p_im 	= @pcy(im)
genr p_img 	= @pcy(img)
genr p_ims 	= @pcy(ims)
genr p_us_gdp = @pcy(usgdp)
genr p_ch_gdp = ch_gdp - 100
genr peugdp = @pcy(eugdp)
genr pjpgdp = @pcy(jpgdp)
genr pcpi = @pcy(cpi)
genr pcore = @pcy(core)
genr pexx = @pcy(exx)
genr pimx = @pcy(imx)
genr pexxus = @pcy(exxus)
genr pimxus = @pcy(imxus)
genr pgdpdef = @pcy(gdpdef)

```







## Model Estimation
We take a note of some rare commands

| command | function |
| ------- | -------- |
| `@movav(x, n)` | n-period backward moving average |
| `@seas(x)` | seasonal dummy |  


### Private Consumption Expenditure

```
smpl 1998q4 @last
equation eq_pce.ls pce c ar(1) @movav(gdp(-1), 4) @seas(2) @seas(3) @seas(4) @isperiod("2009q1") @isperiod("2009q2") @isperiod("2011q1") 
```

### Government Consumption Expenditure
```
smpl 2005q4 @last
' @isperiod("2009q1") corrects the political shock
equation eq_gce.ls gce c @seas(2) @seas(3) @seas(4) @trend @isperiod("2009q1")
```

### Private Capital Investment
```
smpl 1999q2 @last
' Super smooth model instead of accelerator above
equation eq_pricap.ls pricap c @movav(gdp, 2) stockpri(-1) @seas(2) @seas(3) @seas(4) @isperiod("2007q4") @isperiod("2008q1") @isperiod("2008q2") @isperiod("2008q3")
```

### Public Capital Investment
```
smpl 2005q4 @last
equation eq_pubcap.ls pubcap c replacepub @seas(2) @seas(3) @seas(4)
```

### Inventory
```
smpl 1998q1 @last
equation eq_inv.ls inv @seas(1) @seas(2) @seas(3) @seas(4) d(img) d(img(-1)) d(gsales) pg4index ma(1)
```

### Export of Goods
```
smpl 1998q1 @last
equation eq_exg.ls exg c usgdp eugdp jpgdp d(thbusd) @trend @seas(2) @seas(3) @seas(4)
```

### Export of Services
```
smpl 1999q1 @last
equation eq_exs.ls exs c visit @movav(visit, 4) g4index @trend @seas(2) @seas(3) @seas(4)
```

### Import of Goods
```
smpl 1998q1 @last
equation eq_img.ls img c fsales fsales(-1) fsales(-2) fsales(-3) fsales(-4) @isperiod("2005q1") @isperiod("2005q2") @seas(2) @seas(3) @seas(4)
```

### Import of Services
```
smpl 1998q1 @last
equation eq_ims.ls ims c @movav(fsales, 4) @movav(thbusd, 2) @seas(2) @seas(3) @seas(4) @trend @isperiod("2002q2") @isperiod("2003q4") @isperiod("2005q1")
```

### Export Price (Deflator) of Goods
```
smpl @all
equation eq_exg_def.ls exg_def c ar(1) @movav(brent, 4) @movav(usgdp, 2) thbusd cpi
```

### Import Price (Deflator) of Goods
```
smpl @all
equation eq_img_def.ls img_def c ar(1) @movav(brent, 2) thbusd cpi
```

### Export Price (Deflator) of Services
```
smpl 1993q2 @last
equation eq_exs_def.ls exs_def c cpi
```

### Import Price (Deflator) of Services
```
smpl 2000q1 @last
equation eq_ims_def.ls ims_def c ar(1) @movav(brent, 2) @seas(2) @seas(3) @seas(4) @trend
```

### GDP Deflator
```
smpl 1993.2 @last
equation eq_gdp_def.ls gdp_def c pce_def img_def @seas(2) @seas(3) @seas(4) sar(1) sma(1)
```

### PCE Deflator
```
smpl 1993.2 @last
equation eq_pce_def.ls pce_def c cpi @seas(2) @seas(3) @seas(4) 
```

### GCE Deflator
```
smpl 1994.1 @last
equation eq_gce_def.ls gce_def c cpi @seas(2) @seas(3) @seas(4) @trend gdp_def sar(4)
```

### Private Investment Deflator
```
smpl @all
equation eq_pricap_def.ls pricap_def c @movav(brent, 2) @movav(img_def, 2) @seas(2) @seas(3) @seas(4) @trend
```

### Public Investment Deflator
```
smpl @all
equation eq_pubcap_def.ls pubcap_def c @movav(brent, 2) @movav(img_def, 4) @seas(2) @seas(3) @seas(4) @trend sar(1)
```

### Money Supply
```
smpl 2000q1 @last
equation eq_bm.ls bm c @trend gdp cpi ar(1) ma(1)
```








## Model Linkage
Build a new model called `mm` (macroeconometric model) by using this command
```
model smm
```
Merge the equations into the `mm` model
```
mm.merge eqexg
mm.merge eqexs
mm.merge eqpricap
mm.merge eqpubcap
mm.merge eqimg
mm.merge eqims
mm.merge eqinv
mm.merge eqpce
mm.merge eqgce
mm.merge eqexgdef
mm.merge eqimgdef
mm.merge eqexsdef
mm.merge eqimsdef
mm.merge eqgdpdef
mm.merge eqpcedef
mm.merge eqgcedef
mm.merge eqpricapdef
mm.merge eqpubcapdef
mm.merge eqbm
```
Append identities into the `mm` model
```
smm.append gdp  = pce  + gce  + gfcf  + inv  + ex  - im  + sd
smm.append gdpx = gdp*gdpdef/100
smm.append pcex = pce*pcedef/100
smm.append gcex = gce*gcedef/100
smm.append gfcf = pricap + pubcap
smm.append pricapx = pricap*pricapdef/100
smm.append pubcapx = pubcap*pubcapdef/100
smm.append gfcfx = pricapx + pubcapx
smm.append gfcfdef = 100*gfcfx/gfcf
smm.append stock  = (1  - 0.053)  * stock(-1)  + gfcf
smm.append stockpri = (1  - 0.053)  * stockpri(-1)  + pricap
smm.append stockpub = (1  - 0.053)  * stockpub(-1)  + pubcap
smm.append fsales  = pce  + gce  + gfcf  + exg  + exs
smm.append gsales  = pce  + gce  + gfcf  + exg
smm.append replace  = 0.053 * stock
smm.append replacepri = 0.053 * stockpri
smm.append replacepub = 0.053 * stockpub
smm.append ex  = exg  + exs
smm.append im  = img  + ims
smm.append exgx = exg*exgdef/100
smm.append exsx = exs*exsdef/100
smm.append imgx = img*imgdef/100
smm.append imsx = ims*imsdef/100
smm.append exx = exgx + exsx
smm.append imx = imgx + imsx
smm.append exdef = 100*exx/ex
smm.append imdef = 100*imx/im
'Make it in the USD, then we had regression to match up with the BoT numbers
smm.append exgxus = exgx/thbusd
smm.append exsxus = exsx/thbusd
smm.append imgxus = imgx/thbusd
smm.append imsxus = imsx/thbusd
smm.append netserus = exsxus - imsxus
```

Since we are interested in the yearly percentage change of each variable. We also append the yearly percentage change of each variable identity in the `mm` model

```
smm.append pgdp = @pcy(gdp)
smm.append ppce = @pcy(pce)
smm.append pgce = @pcy(gce)
smm.append pgfcf = @pcy(gfcf)
smm.append ppricap = @pcy(pricap)
smm.append ppubcap = @pcy(pubcap)
smm.append pinv = @pcy(inv)
smm.append pex = @pcy(ex)
smm.append pexg = @pcy(exg)
smm.append pexs = @pcy(exs)
smm.append pim = @pcy(im)
smm.append pimg = @pcy(img)
smm.append pims = @pcy(ims)
smm.append pcpi = @pcy(cpi)
smm.append pcore = @pcy(core)
smm.append pvisit = @pcy(visit)
```
