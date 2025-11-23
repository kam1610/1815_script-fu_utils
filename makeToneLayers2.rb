#!/usr/bin/env ruby

require("open3");

############################################################
## mergeLayerFiles
def mergeLayerFiles(layerNames, outFile)
  compositeCmd=
    "convert             " +
    "\"_inFile1_\"       " +
    "\"_inFile2_\"       " +
    "-background white   " +
    "-alpha remove       " +
    "-colorspace Gray    " +
    "-gravity center     " +
    "-geometry +0+0      " +
    "-compose Multiply   " +
    "-composite          " +
    "_outFile_";
  whiteCmd=
    "convert             " +
    "\"_inFile1_\"       " +
    "\"_inFile2_\"       " + # for *white.png file
    "-colorspace Gray    " +
    "-gravity center     " +
    "-geometry +0+0      " +
    "-composite          " +
    "_outFile_";
  runCmd= "";
  whiteFile= "";

  if(layerNames.length < 2)
    return -1;
  end

  # search white file
  0.upto(layerNames.length - 1){|i|
    p layerNames[i];
    if (layerNames[i] =~ /[Ww]hite.png$/)
      whiteFile= layerNames[i];
    end
  }

  # first merge
  runCmd= compositeCmd.sub("_inFile1_" , layerNames.pop());
  runCmd= runCmd.sub(      "_inFile2_" , layerNames.pop());
  runCmd= runCmd.sub(      "_outFile_" , outFile);
  printf(":::: cmd: %s\n", runCmd);
  printf(`#{runCmd}` + "\n");

  while( layerNames.length > 0 )
    runCmd= compositeCmd.sub("_inFile1_" , layerNames.pop());
    runCmd= runCmd.sub(      "_inFile2_" , outFile);
    runCmd= runCmd.sub(      "_outFile_" , outFile);
    printf(":::: cmd: %s\n", runCmd);
    printf(`#{runCmd}` + "\n");
  end

  if(whiteFile != "")
    runCmd= whiteCmd.sub("_inFile1_", outFile);
    runCmd= runCmd.sub(  "_inFile2_", whiteFile);
    runCmd= runCmd.sub(      "_outFile_" , outFile);
    printf(":::: cmd: %s\n", runCmd);
    printf(`#{runCmd}` + "\n");
  end
end

############################################################
## main

gimpGetLayerNameCmd=
  "gimp --batch-interpreter=plug-in-script-fu-eval" +
  "-i -b \"(script-fu-print-layer-name "            +
  "\\\"_filename_\\\") "                            +
  "(gimp-quit TRUE)\"";
gimpSaveLayersToFileCmd=
  "gimp  --batch-interpreter=plug-in-script-fu-eval "       +
  "-i -b \"(script-fu-save-layers-to-files-with-tone-ofst " +
  "\\\"_filename_\\\") "                                    +
  "(gimp-quit TRUE)\"";

numOfLayers   = 0;
layerNames    = [];
layerIsTone   = [];
orderedDither = "h8x8a";
fnl           = [];

if(ARGV.size == 0)
  fnl= Dir.glob("*.xcf")
else
  ARGV.each{|i|
    fnl.push(i);
  }
end
p("fnl:");
p(fnl);

fnl.each{|fn|
  numOfLayers   = 0;
  layerNames    = [];
  layerIsTone   = [];

  fn= File::expand_path(fn);

  ## extract layers
  gimpCmd= gimpSaveLayersToFileCmd.gsub("_filename_", fn);
  printf("run gimp script...\n");
  printf("  file: " + fn + "\n");
  printf("  " + gimpCmd  + "\n");
  printf(`#{gimpCmd}` + "\n");

  ## apply halftone
  Dir.glob(fn+"*"+".png"){|fn2|
    printf(":::::::: file: %s\n", fn2);
    if( (fn2 =~ /#{fn}(k\d+)\.png$/) && ($1 != "k100") )
      layerIsTone.push(true);
      htCmd= sprintf("convert %s "          +
                     "-colorspace Gray    " +
                     "-ordered-dither %s  " +
                     "-background white   " +
                     "-alpha remove       " +
                     "-colorspace Gray    " +
                     "%s",
                     fn2, orderedDither, fn2
                    );
      printf("%s\n", htCmd);
      printf(`#{htCmd}` + "\n");
    else
      layerIsTone.push(false);
    end
    layerNames.push(fn2);

  }
  p(layerNames);
  layerNamesBak= Marshal.load(Marshal.dump(layerNames));
  mergeLayerFiles(layerNames, fn + ".png");
  #cropCmd= "mogrify -crop 2150x3035+164+236 \"" + fn + ".png\"";
  #printf(cropCmd + "\n");
  #printf(`#{cropCmd}` + "\n");
  layerNamesBak.each(){|i|
    rmCmd= "rm \"#{i}\"";
    printf(rmCmd + "\n");
    printf(`#{rmCmd}` + "\n"); # for check
  }

}
