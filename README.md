# Music Genre Classification: GTZAN & Extensions

**Authors:** Alessandro Potenza, Camilla Sed

Reproducible pipeline for benchmarking CNN architectures on GTZAN with transfer learning to additional datasets (FMA Small, Indian Music, Tabla Taala). Focus on methodological rigor and data leak prevention.

## Overview

This repository implements music genre classification with proper evaluation methodology that addresses common data leakage issues in the literature.

### Key Features

- **Leak-free methodology**: Track-level split (60/20/20) before audio slicing (30s → 10×3s segments)
- **Feature extraction**: 128-bin log Mel-spectrograms with train-only scaler fitting
- **CNN architectures**: Efficient_VGG, ResSE_AudioCNN, UNet_Audio_Classifier
- **Evaluation**: Cross-validation, transfer learning, ablation studies
- **Datasets**: GTZAN, FMA Small, Indian Classical Music, Tabla Taala

### Results

| Model | GTZAN Test Accuracy | CV Mean | Transfer Performance |
|-------|-------------------|---------|---------------------|
| U-Net Encoder | 82-83% | ~90% | Strong (Indian/Tabla), Modest (FMA) |
| ResSE_AudioCNN | 79-81% | ~87% | Good across datasets |
| Efficient_VGG | 75-78% | ~85% | Baseline performance |

## Repository Structure

```
notebooks/
├── gtzan/                     # GTZAN experiments
│   ├── 00_setup.ipynb         # Data preprocessing
│   ├── 01_train_tournament.ipynb  # Model comparison
│   └── 01c_kfold_unet.ipynb   # Cross-validation
├── fma/                       # FMA Small experiments
├── indian/                    # Indian Classical Music
├── tabla/                     # Tabla Taala classification
└── final_analysis.ipynb       # Results aggregation
setup.sh                       # Dataset download
requirements.txt               # Dependencies
```

## Quick Start

1. **Setup environment**
   ```bash
   git clone <repo-url> MGC-GTZAN && cd MGC-GTZAN
   python3 -m venv venv && source venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Configure Kaggle API**
   ```bash
   mkdir kaggle/
   cp /path/to/kaggle.json kaggle/
   ```

3. **Download datasets and run**
   ```bash
   bash setup.sh
   jupyter lab
   ```

### Execution Order

1. `notebooks/gtzan/00_setup.ipynb` - Data preparation
2. `notebooks/gtzan/01_train_tournament.ipynb` - Model training
3. `notebooks/final_analysis.ipynb` - Results analysis

## Outputs

- **Models**: `models/` directory (PyTorch `.pth` files)
- **Reports**: `reports/` directory (CSV summaries, classification reports)
- **Metrics**: Training logs and cross-validation results

## Citation

```bibtex
@misc{potenza_sed_mgc_gtzan_2025,
  title={Reproducible Music Genre Classification Benchmark},
  author={Potenza, Alessandro and Sed, Camilla},
  year={2025},
  url={<repo-url>}
}
```

## Requirements

- Python 3.8+
- Kaggle account for dataset download
- ~2GB disk space
