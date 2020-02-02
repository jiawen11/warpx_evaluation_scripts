

Deploy warpx
------------

1. Install MPI (openmpi or mpich)
   sudo apt install openmpi
 
2. git clone https://github.com/sudormroot/warpx_evaluation_scripts.git

3. sh ./deploy_warpx.sh



Profiling
---------

sh ./profile_warpx.sh 1    # with 1 MPI rack


Profiling all cases
-------------------
sh ./run_all.sh

Draw Figures
------------
1. sh ./extract_data.sh <profile-result-dir>
2. python ./draw_figures.py <profile-result-dir>
