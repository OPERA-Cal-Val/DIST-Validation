#!/usr/bin/env perl
use threads; use threads::shared;
$currdir = `pwd`; chomp $currdir;

$layer = $ARGV[0];
$outpath = "DiffANN__$layer"; if (!-d $outpath){mkdir"$outpath";}

#open(OUT,">diff_V_oldM_$layer.csv");
#print OUT"DIST_ID,<=-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,>=10\n";
#close(OUT);
#
#open(OUT,">diff_V_oldM_data_$layer.csv");
#print OUT"DIST_ID,nodata,olddataonly,newdataonly,data\n";
#close(OUT);

my @list :shared;
open(DAT,"tiles.txt") or die "file not found\n"; @list = <DAT>; foreach(@list){chomp;}

#@list =@list[0..1];
#compile();
#compile16();
compileMatrix();
#push(@serverlist, "17,20");
push(@serverlist, "17,20");


@ClassThreads=();
for $line (@serverlist){
($server,$threads)=split(',',$line);
for($threadID=1;$threadID<=$threads;$threadID++){$sline=$server."_".$threadID; push @ClassThreads, threads->create(\&ExpTh, $sline);} }
foreach $thread (@ClassThreads)  {$thread->join();} @ClassThreads=();
print"\n";

sub ExpTh {while($tile = shift(@list)){
  #($HLS,$sensor,$Ttile,$datetime,$majorV,$minorV)= split('\.',$HLS_ID);
  #$DIST_ID = "DIST-ALERT_${datetime}_${sensor}_${Ttile}_v1";
  #$year = substr($datetime,0,4);
  #$tile = substr($Ttile,1,5);
  $zone = substr($tile,0,2);
  $tilepathstring = "$zone/".substr($tile,2,1)."/".substr($tile,3,1)."/".substr($tile,4,1);
  $newpath = "DIST-ANN_v1_VIIRSb/$tilepathstring/2022h";
  $oldpath = "DIST-ANN_v1_current/$tilepathstring/2022h";#/gpfs/glad3/HLSDIST/testing/v1sample/
  $newfile = readpipe"ls $newpath/OPERA*$layer.tif";chomp($newfile);
  $oldfile = readpipe"ls $oldpath/OPERA*$layer.tif";chomp($oldfile);
  if(-e "$newfile"){
    if(-e "$oldfile"){
      #print"ssh gladapp$server \'cd $currdir; ./diff$layer $DIST_ID $newpath $oldpath $zone\'\n";
      system"ssh gladapp$server \'cd $currdir; ./diffMat$layer $newfile $oldfile $zone $tile\'";
    }else{print"missing $oldfile\n";}
  }else{print"missing $newfile\n";}
}}

sub compileMatrix(){
   
open (OUT, ">diffMat$layer.cpp");
print OUT"#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <sys/stat.h>
#include <math.h>
#include <algorithm>
#include <string.h>
#include <stdint.h>
#include <exception>
#include <gdal_priv.h>
#include <cpl_conv.h>
#include <ogr_spatialref.h>
using namespace std;

int main(int argc, char* argv[])
{
//arguments
if (argc != 5){cout << \"wrong argument\" <<endl; exit (1);}
string newfile=argv[1];
string oldfile=argv[2];
int zone = atoi (argv[3]);
string tile = argv[4];
string filename;

//GDAL
GDALAllRegister();
GDALDataset  *INGDAL;
GDALDataset  *SGDAL;
GDALRasterBand  *INBAND;

//counters
int ysize, xsize;
int y, x;

filename=newfile;
INGDAL = (GDALDataset *) GDALOpen( filename.c_str(), GA_ReadOnly ); INBAND = INGDAL->GetRasterBand(1);
ysize = INBAND->GetYSize();xsize = INBAND->GetXSize();
double GeoTransform[6];
INGDAL->GetGeoTransform(GeoTransform);

uint8_t newf[ysize][xsize];
uint8_t oldf[ysize][xsize];

INBAND->RasterIO(GF_Read, 0, 0, xsize, ysize, newf, xsize, ysize, GDT_Byte, 0, 0); GDALClose(INGDAL);


filename=oldfile;
INGDAL = (GDALDataset *) GDALOpen( filename.c_str(), GA_ReadOnly ); INBAND = INGDAL->GetRasterBand(1);
INBAND->RasterIO(GF_Read, 0, 0, xsize, ysize, oldf, xsize, ysize, GDT_Byte, 0, 0); GDALClose(INGDAL);

uint8_t diff[ysize][xsize];memset(diff, 255, sizeof(diff[0][0]) * ysize * xsize);
int hist[9][9]; memset(hist, 0, sizeof(hist[0][0]) * 9 * 9);
int data[4] = {0};

for(y=0; y<ysize; y++) {for(x=0; x<xsize; x++) {
  if(newf[y][x] != 255 and oldf[y][x] != 255){//valid land observation
    hist[newf[y][x]][oldf[y][x]]++;
  } 
}}

ofstream outhist;
outhist.open(\"$outpath/\"+tile+\".txt\");

int sum = 0;
for(int i =0; i<9; i++){
	for(int j =0; j<9; j++){
		outhist<< hist[i][j] << ',';
	}
	outhist <<endl;
}

outhist.close();

return 0;
}";
    close (OUT);
    system("ssh gladapp17 \'cd $currdir; g++ diffMat$layer.cpp -o diffMat$layer -lgdal -Wno-unused-result -std=gnu++11 1>/dev/null\'");
}


sub compile(){
   
open (OUT, ">diff$layer.cpp");
print OUT"#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <sys/stat.h>
#include <math.h>
#include <algorithm>
#include <string.h>
#include <stdint.h>
#include <exception>
#include <gdal_priv.h>
#include <cpl_conv.h>
#include <ogr_spatialref.h>
using namespace std;

int main(int argc, char* argv[])
{
//arguments
if (argc != 5){cout << \"wrong argument\" <<endl; exit (1);}
string DISTID = argv[1];
string newpath=argv[2];
string oldpath=argv[3];
int zone = atoi (argv[4]);
string filename;

//GDAL
GDALAllRegister();
GDALDataset  *INGDAL;
GDALDataset  *SGDAL;
GDALRasterBand  *INBAND;

//counters
int ysize, xsize;
int y, x;

filename=newpath+\"/\"+DISTID+\"_$layer.tif\";
INGDAL = (GDALDataset *) GDALOpen( filename.c_str(), GA_ReadOnly ); INBAND = INGDAL->GetRasterBand(1);
ysize = INBAND->GetYSize();xsize = INBAND->GetXSize();
double GeoTransform[6];
INGDAL->GetGeoTransform(GeoTransform);

uint8_t newf[ysize][xsize];
uint8_t oldf[ysize][xsize];

INBAND->RasterIO(GF_Read, 0, 0, xsize, ysize, newf, xsize, ysize, GDT_Byte, 0, 0); GDALClose(INGDAL);


filename=oldpath+\"/\"+DISTID+\"_$layer.tif\";
INGDAL = (GDALDataset *) GDALOpen( filename.c_str(), GA_ReadOnly ); INBAND = INGDAL->GetRasterBand(1);
INBAND->RasterIO(GF_Read, 0, 0, xsize, ysize, oldf, xsize, ysize, GDT_Byte, 0, 0); GDALClose(INGDAL);

uint8_t diff[ysize][xsize];memset(diff, 255, sizeof(diff[0][0]) * ysize * xsize);
int hist[202] = {0};
int data[4] = {0};

for(y=0; y<ysize; y++) {for(x=0; x<xsize; x++) {
  if(newf[y][x] != 255 and oldf[y][x] != 255){//valid land observation
    diff[y][x] = (int)newf[y][x] + 100 - oldf[y][x];
    hist[diff[y][x]]++;
    data[3]++;
  } else if(newf[y][x] == 255 and oldf[y][x] == 255){data[0]++;}
  else if(newf[y][x] == 255 and oldf[y][x] != 255){data[1]++;}
  else if(newf[y][x] != 255 and oldf[y][x] == 255){data[2]++;}
}}

ofstream outhist;
outhist.open(\"diff_V_oldM_$layer.csv\",ios_base::app);

int sum = 0;
for(int i =-100; i<=-10; i++){sum += hist[i+100];}
outhist<< DISTID << ',' << sum << ',';

for(int i =-9; i<=9; i++){outhist << hist[i+100] << ',';}

sum=0;
for(int i =10; i<=100; i++){sum += hist[i+100];}
outhist<< sum << endl;
outhist.close();

ofstream datadiff;
datadiff.open(\"diff_V_oldM_data_$layer.csv\",ios_base::app);
datadiff << DISTID << ',' << data[0] << ',' << data[1] << ',' << data[2] << ',' << data[3] << endl;
datadiff.close();

//export results
GDALDriver *OUTDRIVER;
GDALDataset *OUTGDAL;
GDALRasterBand *OUTBAND;
OGRSpatialReference oSRS;
char *OUTPRJ = NULL;
char **papszOptions = NULL;

OUTDRIVER = GetGDALDriverManager()->GetDriverByName(\"GTiff\"); if( OUTDRIVER == NULL ) {cout << \"no driver\" << endl; exit( 1 );};
oSRS.SetWellKnownGeogCS( \"WGS84\" );
oSRS.SetUTM( zone, TRUE);
oSRS.exportToWkt( &OUTPRJ );
papszOptions = CSLSetNameValue( papszOptions, \"COMPRESS\", \"DEFLATE\");
papszOptions = CSLSetNameValue( papszOptions, \"TILED\", \"YES\");

const int Noverviews = 3;
int overviewList[Noverviews] = {2,4,8};

filename = \"$outpath/\"+DISTID+\"_diff$layer.tif\";
OUTGDAL = OUTDRIVER->Create( filename.c_str(), xsize, ysize, 1, GDT_Byte, papszOptions );
OUTGDAL->SetGeoTransform(GeoTransform); OUTGDAL->SetProjection(OUTPRJ); OUTBAND = OUTGDAL->GetRasterBand(1);
OUTBAND->SetNoDataValue(255);
OUTBAND->RasterIO( GF_Write, 0, 0, xsize, ysize, diff, xsize, ysize, GDT_Byte, 0, 0 ); 
OUTGDAL->BuildOverviews(\"NEAREST\",Noverviews,overviewList,0,nullptr, GDALDummyProgress, nullptr );
GDALClose((GDALDatasetH)OUTGDAL);


return 0;
}";
    close (OUT);
    system("g++ diff$layer.cpp -o diff$layer -lgdal -Wno-unused-result -std=gnu++11 1>/dev/null");
}


sub compile16(){
   
open (OUT, ">diff$layer.cpp");
print OUT"#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <sys/stat.h>
#include <math.h>
#include <algorithm>
#include <string.h>
#include <stdint.h>
#include <exception>
#include <gdal_priv.h>
#include <cpl_conv.h>
#include <ogr_spatialref.h>
using namespace std;

int main(int argc, char* argv[])
{
//arguments
if (argc != 5){cout << \"wrong argument\" <<endl; exit (1);}
string DISTID = argv[1];
string newpath=argv[2];
string oldpath=argv[3];
int zone = atoi (argv[4]);
string filename;

//GDAL
GDALAllRegister();
GDALDataset  *INGDAL;
GDALRasterBand  *INBAND;

//counters
int ysize, xsize;
int y, x;

filename=newpath+\"/\"+DISTID+\"_$layer.tif\";
INGDAL = (GDALDataset *) GDALOpen( filename.c_str(), GA_ReadOnly ); INBAND = INGDAL->GetRasterBand(1);
ysize = INBAND->GetYSize();xsize = INBAND->GetXSize();
double GeoTransform[6];
INGDAL->GetGeoTransform(GeoTransform);

short newf[ysize][xsize];
short oldf[ysize][xsize];

INBAND->RasterIO(GF_Read, 0, 0, xsize, ysize, newf, xsize, ysize, GDT_Int16, 0, 0); GDALClose(INGDAL);


filename=oldpath+\"/\"+DISTID+\"_$layer.tif\";
INGDAL = (GDALDataset *) GDALOpen( filename.c_str(), GA_ReadOnly ); INBAND = INGDAL->GetRasterBand(1);
INBAND->RasterIO(GF_Read, 0, 0, xsize, ysize, oldf, xsize, ysize, GDT_Int16, 0, 0); GDALClose(INGDAL);

uint8_t diff[ysize][xsize];memset(diff, 255, sizeof(diff[0][0]) * ysize * xsize);
int hist[202] = {0};
int data[4] = {0};

for(y=0; y<ysize; y++) {for(x=0; x<xsize; x++) {
  if(newf[y][x] >= 0 and oldf[y][x] >= 0){//valid land observation
    if(newf[y][x]>100){newf[y][x]=100;}
    if(oldf[y][x]>100){oldf[y][x]=100;}
    diff[y][x] = newf[y][x] + 100 - oldf[y][x];
    hist[diff[y][x]]++;
    data[3]++;
  } else if(newf[y][x] < 0 and oldf[y][x] < 0){data[0]++;}
  else if(newf[y][x] < 0 and oldf[y][x] >= 0){data[1]++;}
  else if(newf[y][x] >= 0 and oldf[y][x] < 0){data[2]++;}
}}

ofstream outhist;
outhist.open(\"diff_V_oldM_$layer.csv\",ios_base::app);

int sum = 0;
for(int i =-100; i<=-10; i++){sum += hist[i+100];}
outhist<< DISTID << ',' << sum << ',';

for(int i =-9; i<=9; i++){outhist << hist[i+100] << ',';}

sum=0;
for(int i =10; i<=100; i++){sum += hist[i+100];}
outhist<< sum << endl;
outhist.close();

ofstream datadiff;
datadiff.open(\"diff_V_oldM_data_$layer.csv\",ios_base::app);
datadiff << DISTID << ',' << data[0] << ',' << data[1] << ',' << data[2] << ',' << data[3] << endl;
datadiff.close();

//export results
GDALDriver *OUTDRIVER;
GDALDataset *OUTGDAL;
GDALRasterBand *OUTBAND;
OGRSpatialReference oSRS;
char *OUTPRJ = NULL;
char **papszOptions = NULL;

OUTDRIVER = GetGDALDriverManager()->GetDriverByName(\"GTiff\"); if( OUTDRIVER == NULL ) {cout << \"no driver\" << endl; exit( 1 );};
oSRS.SetWellKnownGeogCS( \"WGS84\" );
oSRS.SetUTM( zone, TRUE);
oSRS.exportToWkt( &OUTPRJ );
papszOptions = CSLSetNameValue( papszOptions, \"COMPRESS\", \"DEFLATE\");
papszOptions = CSLSetNameValue( papszOptions, \"TILED\", \"YES\");

const int Noverviews = 3;
int overviewList[Noverviews] = {2,4,8};

string filename2 = \"$outpath/\"+DISTID+\"_diff$layer.tif\";
OUTGDAL = OUTDRIVER->Create( filename2.c_str(), xsize, ysize, 1, GDT_Byte, papszOptions );
OUTGDAL->SetGeoTransform(GeoTransform); OUTGDAL->SetProjection(OUTPRJ); OUTBAND = OUTGDAL->GetRasterBand(1);
OUTBAND->SetNoDataValue(255);
OUTBAND->RasterIO( GF_Write, 0, 0, xsize, ysize, diff, xsize, ysize, GDT_Byte, 0, 0 ); 
OUTGDAL->BuildOverviews(\"NEAREST\",Noverviews,overviewList,0,nullptr, GDALDummyProgress, nullptr );
GDALClose((GDALDatasetH)OUTGDAL);


return 0;
}";
    close (OUT);
    system("g++ diff$layer.cpp -o diff$layer -lgdal -Wno-unused-result -std=gnu++11 1>/dev/null");
}