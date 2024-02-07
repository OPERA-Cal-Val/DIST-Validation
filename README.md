## DIST-Validation
Tools for validating DIST-ALERT and DIST-ANN

#Accuracy based on statistical sample of time-series reference data



#Comparison of DIST-ALERT and DIST-ANN derived from HLS processed with VIIRS and LaSRC 3.5.1 vs with MODIS and LaSRC 3.0.5
1.	Comparison of layers derived from just the current granule plus the baseline
For this comparison we ran the VEG-IND, VEG-ANOM, and GEN-ANOM layers for both sets of HLS data by changing the parameters.py to source the correct HLS (ln3) and define the output folder (ln 4) and then running anom_manager.py (>python anom_manager.py filelist.txt ALL) . We then ran getDiff.pl to generate the difference histograms for each of these layers and analyzed the results in the respective Excel workbooks.

2.	Comparison of time-series results 
For this comparison we first ran sameFiles.pl to generate a list of the comparable HLS data between the two sets (VIIRS-based and MODIS-based). We then applied DIST-ALERT to all the dates by running DIST_ALL.py (>python DIST_ALL.py samefiles.txt RESTART False) and changing the parameters.py file to source the correct HLS (ln3) and define the output folder (ln 4). We then generated difference matrices of VEG-DIST-STATUS of DIST-ALERT for the last date of each tile and copied the results into VIIRStimeSeriesCompareTables.xlsx. We also ran DIST-ANN (>perl annualManager.pl tiles.txt 2021274 2022273 2022h) to compare VEG-DIST-STATUS. Run “perl getDiff.pl VEG-DIST-STATUS” and “perl getDiffMat.pl VEG-DIST-STATUS” to get the agreement matrices.

