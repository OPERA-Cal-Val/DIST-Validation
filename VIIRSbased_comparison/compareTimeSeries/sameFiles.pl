@files = readpipe"ls */?30*_VIIRS/*/HLS*.B04.tif";
$Nfiles = @files;
print("$Nfiles\n");$i=1;
open(OUT,">samefiles.txt");
foreach $fpath (@files){
	chomp($fpath);
	#print"\r$i / $Nfiles";$i++;
	@folders = split('/',$fpath);$HLS=$folders[-2];
	$fbase = substr($fpath,0,-10);
	($name,$sensor,$Ttile,$datetime,$majorV,$minorV) = split('\.',$HLS);
	$tile = substr($Ttile,1,5);
	$zone = substr($tile,0,2);
	$year = substr($datetime,0,4);
	$tilepathstring = "$zone/".substr($tile,2,1)."/".substr($tile,3,1)."/".substr($tile,4,1);
	#system"mkdir -p VIIRS/$sensor/$year/$tilepathstring/$HLS";
	#for $b ("Fmask","B04","B05","B06","B07"){
	#	system"cp $fbase.$b.tif VIIRS/$sensor/$year/$tilepathstring/$HLS/$HLS.$b.tif\n";
	#}
	#system"cp $fbase.cmr.xml VIIRS/$sensor/$year/$tilepathstring/$HLS/$HLS.cmr.xml\n";
	if(-d "/gpfs/glad3/HLS/$sensor/$year/$tilepathstring/$HLS"){
		$spat = readpipe"gdalinfo $fpath | grep -h \"spatial_coverage\"";chomp($spat);($t,$spatnew) = split('=',$spat);
		$spat = readpipe"gdalinfo /gpfs/glad3/HLS/$sensor/$year/$tilepathstring/$HLS/$HLS.B04.tif | grep -h \"spatial_coverage\"";chomp($spat);($t,$spatold) = split('=',$spat);
		if($spatold ne $spatnew){
			print"$spatold,$spatnew,$HLS\n";
		}else{print OUT"$HLS\n";}
	}#else{print"\n/gpfs/glad3/HLS/$sensor/$year/$tilepathstring/$HLS not in archive\n";}
}