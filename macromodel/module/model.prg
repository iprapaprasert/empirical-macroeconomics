' Empirical Macroeconomics Part II: Macroeconomic Model
' Module 4: Model
' include addshift

' Create new model
model mm

' Add equations
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

' Add identities
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

'' Denominated in USD
mm.append exgxus = exgx / thbusd
mm.append exsxus = exsx / thbusd
mm.append imgxus = imgx / thbusd
mm.append imsxus = imsx / thbusd
mm.append netserus = exsxus - imsxus

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


