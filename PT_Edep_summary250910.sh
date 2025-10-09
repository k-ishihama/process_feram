#!/bin/bash

#SBATCH -p i1fat
#SBATCH -N 1
#SBATCH -n 8
#SBATCH -c 8
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=kishihama@quemix.com

module purge
module load oneapi_compiler/2023.0.0
module load oneapi_mpi/2023.0.0
module load oneapi_mkl/2023.0.0

#print the current date and time
echo "Current date and time: $(date)"

BIN=${HOME}/local/film_feram/019_241006/build/src

BASE_DIR=$(pwd)
COORD_DIR="/home2/k0463/k046316/lab/feram/17PT/25_PT900to300K_-1to3per/5_scan_acoustic_900K/coord"
# 改良点1: ディレクトリと数値のペアを配列で管理
DIRS=(
    "1_z0.0200_300K.0000040000.coord:0.0200"
    "2_z0.0180_300K.0000040000.coord:0.0180"
    "3_z0.0160_300K.0000040000.coord:0.0160"
    "4_z0.0140_300K.0000040000.coord:0.0140"
    "5_z0.0120_300K.0000040000.coord:0.0120"
    "6_z0.0100_300K.0000040000.coord:0.0100"
    "7_z0.0080_300K.0000040000.coord:0.0080"
    "8_z0.0060_300K.0000040000.coord:0.0060"
    "9_z0.0040_300K.0000040000.coord:0.0040"
    "10_z0.0020_300K.0000040000.coord:0.0020"
    "11_z0.0000_300K.0000040000.coord:0.0000"
    "12_z-0.0020_300K.0000040000.coord:-0.0020"
    "13_z-0.0040_300K.0000040000.coord:-0.0040"
    "14_z-0.0060_300K.0000040000.coord:-0.0060"
    "15_z-0.0080_300K.0000040000.coord:-0.0080"
    "16_z-0.0100_300K.0000040000.coord:-0.0100"
    "17_z-0.0120_300K.0000040000.coord:-0.0120"
    "18_z-0.0140_300K.0000040000.coord:-0.0140"
    "19_z-0.0160_300K.0000040000.coord:-0.0160"
    "20_z-0.0180_300K.0000040000.coord:-0.0180"
    "21_z-0.0200_300K.0000040000.coord:-0.0200"
    "22_z0.0190_300K.0000040000.coord:0.0190"
    "23_z0.0170_300K.0000040000.coord:0.0170"
    "24_z0.0150_300K.0000040000.coord:0.0150"
    "25_z0.0130_300K.0000040000.coord:0.0130"
    "26_z0.0110_300K.0000040000.coord:0.0110"
    "27_z0.0090_300K.0000040000.coord:0.0090"
    "28_z0.0070_300K.0000040000.coord:0.0070"
    "29_z0.0050_300K.0000040000.coord:0.0050"
    "30_z0.0030_300K.0000040000.coord:0.0030"
    "31_z0.0010_300K.0000040000.coord:0.0010"
    "32_z-0.0010_300K.0000040000.coord:-0.0010"
)

run_job() {
    local coord_name="$1"
    local strain_value="$2"
    local coord_dir="$3"

    local coord_name_new=${coord_name%_300K.*}
    local dir_path_new="$BASE_DIR/$coord_name_new"
    mkdir -p $dir_path_new


    cd $dir_path_new || { echo "[ERROR] Directory not found: $dir_path_new"; return 1; }

    mkdir -p 1_E030l_$strain_value
    cd ./1_E030l_$strain_value || return 1

    sed "s/epi_strain = strain_value/epi_strain = $strain_value/g" \
        ../../sin-PT300K.feram > sin-PT300K.feram
    ln -s $coord_dir/$coord_name ./sin-PT300K.restart
    #cp -r ../coord_files/*300K*coord ./sin-PT300K.restart

    echo "Running job in $dir_path_new (strain=$strain_value)"
    $BIN/feram sin-PT300K.feram

    mkdir -p coord_files fft_files
    mv *.coord ./coord_files 2>/dev/null
    mv *.fft ./fft_files 2>/dev/null

    cd "$BASE_DIR" || return 1
}


for dir_entry in "${DIRS[@]}"; do
    IFS=':' read -r dir_path strain_value <<< "$dir_entry"
    run_job "$dir_path" "$strain_value" "$COORD_DIR"&
done

wait
echo "All jobs completed."
echo "Current date and time: $(date)"
