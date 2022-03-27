# Batch-Process-PTR-MS
PTRMS data processing includes
- subtract ions count from baseline ions count (baseline signals from N2 gas)
- divide the subtracted ions count by sensitivity -> convert ions count to VOC mixing ratio (ppb)
Note:
- sensitivity depends on the performance of the instrument at the time -> different sensitivities files to be used for different periods of time
- make sure no. of data file & no. of baseline files is the same
- make sure baseline file name has "_Baseline.csv"
