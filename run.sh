NORM_EXP=$1
NET_FILE=$2
OUTPUT=$3 
CPU=$4

SEED=123
PERCENT=0.1
PYTHON="python"
RSCRIPT="Rscript"
CUTOFF=0.05

$PYTHON step1_BuildIndex.py $NET_FILE $NORM_EXP $OUTPUT\.data $PERCENT
$PYTHON step2_CalZmat.py $OUTPUT\.data $OUTPUT\.data.zmat $CPU
$RSCRIPT step3_deMix.R $NORM_EXP $OUTPUT\.data.zmat $OUTPUT\.data.zmat.gca_result $CPU $SEED $CUTOFF
$PYTHON step4_getRegFeature.py  $NET_FILE  $OUTPUT\.data.zmat.gca_result MODE_MAT.txt
