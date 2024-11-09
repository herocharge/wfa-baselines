BASELINES_PATH=$(pwd)

# Build deps
cd $BASELINES_PATH/external/wfa-gpu; ./build.sh

# Go back to baselines
cd $BASELINES_PATH

# Create wrappers around baseline binaries
echo -e "#!/bin/bash\n$BASELINES_PATH/external/wfa-gpu/bin/wfa.affine.gpu \$@" > gpu_baseline.sh && chmod +x gpu_baseline.sh
echo -e "#!/bin/bash\n$BASELINES_PATH/external/wfa-gpu/external/WFA/bin/align_benchmark \$@" > cpu_baseline.sh && chmod +x cpu_baseline.sh

# Create wrapper aroung 
echo -e "#!/bin/bash\n$BASELINES_PATH/external/wfa-gpu/external/WFA/bin/generate_dataset \$@" > generate_dataset.sh && chmod +x generate_dataset.sh





