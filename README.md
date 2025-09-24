## Music Genre Classification (GTZAN & Extensions)

Authors: Alessandro Potenza, Camilla Sed

Minimal, reproducible pipeline for benchmarking CNN architectures on GTZAN and transferring a U-Net encoder to additional datasets (FMA Small, Indian Music, Tabla Taala). Focus: methodological rigor (no data leakage) and honest replication of inflated claims.

### Key Points
- Leak-free: track-level split (60/20/20) BEFORE slicing 30s → 10×3s.
- Features: 128-bin log Mel-spectrograms; scaler fit on train only.
- Models: Efficient_VGG (baseline), ResSE_AudioCNN, UNet_Audio_Classifier (encoder-only champion).
- Results (single split GTZAN): U-Net ≈ 82–83% test accuracy; CV mean ≈ 90% (val). Transfer strong on Indian / Tabla; modest on FMA (from scratch).
- SpecAugment helps only U-Net (capacity-dependent).

### Repo Structure (simplified)
```
notebooks/gtzan (prep, train, cv)
notebooks/{fma,indian,tabla}
notebooks/final_analysis.ipynb
models/            # Saved .keras
reports/           # *.csv, classification reports
setup.sh           # Download + prepare GTZAN
requirements.txt
```

### Quick Start
```bash
git clone <repo-url> MGC-GTZAN
cd MGC-GTZAN
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp /path/to/kaggle.json kaggle/
bash setup.sh           # downloads GTZAN
jupyter lab             # run notebooks in order
```
Order: gtzan/00_setup → gtzan/01_train_tournament → final_analysis (+ optional CV + other datasets).

Important: place your personal Kaggle API token file `kaggle.json` inside the `kaggle/` directory (created in the repo) *before* running `bash setup.sh`, otherwise the dataset download will fail.

### Outputs
Models: `models/`  • Summaries: `reports/training_summary_*.csv`  • CV: `kfold_cv_unet_gtzan*.csv`  • Classification reports & metrics in `reports/`.

### Citation (placeholder)
```
@misc{potenza_sed_mgc_gtzan_2025,
  title={Reproducible Music Genre Classification Benchmark},
  author={Potenza, Alessandro and Sed, Camilla},
  year={2025},
  url={<repo-url>}
}
```

Add a license file (e.g. MIT) if distributing publicly.
