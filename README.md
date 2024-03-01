# DIST-Validation
Tools for validating DIST-ALERT and DIST-ANN

## Accuracy based on statistical sample of time-series reference data
DIST-ALERT and DIST-ANN were validated using a stratified random sample of time-series reference data. A global stratification was derived for 2021-10-01 through 2022-09-30 and fifty 30 m pixels were selected per stratum as sample units, resulting in 300 sample units. The values of VEG-DIST-STATUS, which is a summary of the current disturbance status, of DIST-ALERT were compared against the same date in the reference time-series data to assess the accuracy.

### Input data
The list of sample units and the locations are found in sampledpixels1214.csv. The DIST-ALERT labels per each sample unit are found in mapLabelsv1sample/[unit ID]_DIST-ALERT_v1sample.csv. These tables provide the granule ID, the sensing time, and the values of the data layers for each date through the evaluation year. The DIST-ANN values are in one combined table, mapLabelsv1sample/All_DIST-ANN_v1sample.csv. The reference time-series data per sample unit is found in the table referenceTimeSeries_last.csv. These data were extracted and compiled with Extract_map_ref_data.ipynb. Strata areas and counts are found in stratatable_0119_z.txt.

### Accuracy caluclations
All accuracy calculations are included within the Accuracy_v1.ipynb notebook.

#### Summary results
DIST-ALERT_v1
For each observed date through the time-series, no-dist and ongoing-dist are compared against the reference time-series for the previous 30 days and finished-dist are compared against the reference time-series year to date. A disturbance must persist in the reference data for at least 15 days (this correspons with the map moving window being +-15 days).

- High magnitude loss for both map and reference (Map ≥50%, ref VLmaj): Users 63.3 ±64.5, Producers 58.2±15.3
    - only confirmed: users 77.3 ±21.3, producers 58.0 ±15.4
- Map high loss, ref any loss: users 75.1 ±96.9
    - only confirmed: **users 99.2 ±2.6**
- Map any loss, ref high loss: **producers 92.0 ±7.1**
    - only confirmed: producers 90.3 ±7.6
- Map any loss, ref any loss: users 44.8 ±24.0 prod 57.9 ±28.3
    - Only confirmed: users 71.0 ±10.9 prod 51.2 ±26.2

All of these variations have overall accuracy >98%. For the variations where only users or producers are listed, the other is very low (almost by definition).

This means that 63% of high loss alerts were also high loss in the reference with an additional 19% having loss labeled “minority” in the reference. For only confirmed this is 73% and an additional 22% as “minority”. Out of all the “majority” loss identified in the reference, 89% was detected by the product with 88% reaching confirmed status.

## Comparison of DIST-ALERT and DIST-ANN derived from HLS processed with VIIRS and LaSRC 3.5.1 vs with MODIS and LaSRC 3.0.5
1.	Comparison of layers derived from just the current granule plus the baseline
For this comparison we ran the VEG-IND, VEG-ANOM, and GEN-ANOM layers for both sets of HLS data by changing the parameters.py to source the correct HLS (ln3) and define the output folder (ln 4) and then running anom_manager.py (>python anom_manager.py filelist.txt ALL) . We then ran getDiff.pl to generate the difference histograms for each of these layers and analyzed the results in the respective Excel workbooks.

2.	Comparison of time-series results 
For this comparison we first ran sameFiles.pl to generate a list of the comparable HLS data between the two sets (VIIRS-based and MODIS-based). We then applied DIST-ALERT to all the dates by running DIST_ALL.py (>python DIST_ALL.py samefiles.txt RESTART False) and changing the parameters.py file to source the correct HLS (ln3) and define the output folder (ln 4). We then generated difference matrices of VEG-DIST-STATUS of DIST-ALERT for the last date of each tile and copied the results into VIIRStimeSeriesCompareTables.xlsx. We also ran DIST-ANN (>perl annualManager.pl tiles.txt 2021274 2022273 2022h) to compare VEG-DIST-STATUS. Run “perl getDiff.pl VEG-DIST-STATUS” and “perl getDiffMat.pl VEG-DIST-STATUS” to get the agreement matrices.

