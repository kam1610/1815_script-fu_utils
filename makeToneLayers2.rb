#!/usr/bin/env ruby

require("open3");
require("tmpdir");
require("fileutils");

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

##./makeToneLayer2.rb <srcfile> <dstdir> [workdir]

gimpSaveLayersToFileCmd=
  "gimp  --batch-interpreter=plug-in-script-fu-eval "       +
  "-i -b \"(script-fu-save-layers-to-files-with-tone-ofst " +
  "\\\"_filename_\\\") "                                    +
  "(gimp-quit TRUE)\"";

numOfLayers   = 0;
layerNames    = [];
layerIsTone   = [];
orderedDither = "h8x8a";
fn            = "";
dstdir        = "";
tmpdir_base   = "/dev/shm";

if((ARGV.size != 2) && (ARGV.size != 3))
  printf("usage: makeToneLayer2.rb <srcfile> <dstdir> [workdir]\n");
  exit(0);
else
  fn     = File::expand_path(ARGV[0]);
  dstdir = ARGV[1];
end
if(ARGV.size == 3)
  tmpdir_base = ARGV[2];
end

Dir.mktmpdir(nil, tmpdir_base){|dir|
  # copy file to tmpdir and change current dir
  FileUtils.cp(fn, dir, verbose:true);
  Dir.chdir(dir);

  numOfLayers   = 0;
  layerNames    = [];
  layerIsTone   = [];
  fn_base       = File.basename(fn);

  ## extract layers
  gimpCmd= gimpSaveLayersToFileCmd.gsub("_filename_", fn_base);
  printf("run gimp script...\n");
  printf("  file: " + fn_base + "\n");
  printf("  " + gimpCmd  + "\n");
  printf(`#{gimpCmd}` + "\n");

  ## apply halftone
  Dir.glob(fn_base+"*"+".png"){|fn2|
    printf(":::::::: file: %s\n", fn2);
    if( (fn2 =~ /#{fn_base}(k\d+)\.png$/) && ($1 != "k100") )
      printf("tonelayer: %s\n", fn2);
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
      printf("gslayer: %s\n", fn2);
      layerIsTone.push(false);
    end
    layerNames.push(fn2);

  }
  p(layerNames);
  layerNamesBak= Marshal.load(Marshal.dump(layerNames));

  outfile = fn_base + ".png";
  mergeLayerFiles(layerNames, outfile);
  FileUtils.mv(dir + "/" + outfile,
               dstdir + "/" + outfile, verbose:true);
}
