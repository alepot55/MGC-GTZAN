# State-of-the-Art Music Genre Classification

**Authors:** Alessandro Potenza, Camilla Sed  
**Course:** Numerical Analysis for Machine Learning, Politecnico di Milano

---

## 1. Project Overview

This project provides a rigorous and reproducible investigation into Music Genre Classification (MGC) using the benchmark GTZAN dataset. The work is motivated by the reproducibility challenges prevalent in the field, where many published results report near-perfect accuracies that are difficult to verify and likely stem from methodological flaws.

Our primary contribution is twofold:
1.  **Establishing a Gold-Standard Pipeline:** We designed and implemented a data pre-processing and evaluation framework that explicitly prevents data leakage, a common pitfall in MGC research.
2.  **A Systematic Architectural Study:** Using this robust pipeline, we conducted a comparative analysis of three distinct deep learning architectures. This study culminates in establishing a reliable State-of-the-Art (SOTA) performance on GTZAN and provides a clear narrative on architectural evolution for this specific task.

Our final **U-Net-inspired classifier achieves a test accuracy of 83.5%**, demonstrating the superiority of a multi-scale feature learning approach. The entire project, from data preparation to final analysis, is documented and open-sourced to ensure full transparency and reproducibility.

---

## 2. Repository Structure

The project is organized into a clean and logical directory structure:

```
.
├── models/              # Saved .keras models from the final training run.
├── notebooks/           # Jupyter notebooks detailing the project workflow.
│   ├── 00_Setup_and_Data_Preparation.ipynb
│   ├── 01_Model_Training_Tournament.ipynb
│   └── 02_Analysis_and_Publication_Results.ipynb
├── paper.pdf            # The final research paper in PDF format.
├── reports/             # All generated figures, tables, and reports.
├── requirements.txt     # Python dependencies for the project.
├── setup.sh             # Shell script to set up the environment and data.
└── README.md            # This file.
```

---

## 3. The Research Workflow: A Three-Notebook Journey

Our research process is documented across three distinct Jupyter notebooks, each with a specific responsibility. This separation ensures a clean and reproducible workflow.

### 📓 `00_Setup_and_Data_Preparation.ipynb`
This notebook is the foundation of the project. It handles the critical task of preparing the GTZAN dataset.

-   **Input:** Raw GTZAN audio files.
-   **Process:**
    1.  Performs a leak-free, stratified split of the *file paths* (60% train, 20% validation, 20% test).
    2.  Augments the data by segmenting each 30-second clip into 10 smaller chunks.
    3.  Extracts Mel-spectrograms from each audio segment.
    4.  Standardizes features by fitting a scaler **only on the training data**.
-   **Output:** Processed NumPy arrays (`X_train`, `y_train`, etc.) and fitted `scaler`/`label_encoder` objects saved to the `data/processed` directory (not tracked by Git).

### 📓 `01_Model_Training_Tournament.ipynb`
This is the primary computation notebook. It takes the processed data and runs our definitive comparative analysis.

-   **Input:** The processed data arrays from Notebook 00.
-   **Process:**
    1.  Defines our three curated architectures: `Efficient_VGG`, `ResSE_AudioCNN`, and `UNet_Audio_Classifier`.
    2.  Systematically trains and evaluates each model under identical conditions.
    3.  Uses robust callbacks for early stopping, learning rate reduction, and saving the best model weights.
-   **Output:**
    -   Best model weights (`.keras` files) saved to the `models/` directory.
    -   A final summary CSV (`training_summary_final.csv`) saved to the `reports/` directory.

### 📓 `02_Analysis_and_Publication_Results.ipynb`
This notebook is purely for analysis and visualization. It **does not train any models**.

-   **Input:** The `training_summary_final.csv` and the best `.keras` models.
-   **Process:**
    1.  Loads the tournament results and identifies the champion model.
    2.  Generates publication-quality visualizations:
        -   A bar chart comparing the performance of the three models.
        -   A detailed confusion matrix for the champion model.
        -   A t-SNE plot to visualize the learned feature embeddings.
    3.  Generates a detailed classification report with per-class metrics.
-   **Output:** All figures and text reports saved to the `reports/` directory.

---

## 4. How to Reproduce

Follow these steps to set up the environment and reproduce our results.

### Step 1: Clone the Repository
```bash
git clone <your-repository-url>
cd naml_project
```

### Step 2: Set Up the Environment
Create a Python virtual environment and install the required dependencies.
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Step 3: Download and Prepare Data
Run the `setup.sh` script. This script will:
1.  Create the necessary directory structure (`data/raw`, `data/processed`).
2.  Set up the Kaggle API credentials (you must have your `kaggle.json` file in the `kaggle/` directory).
3.  Download the GTZAN dataset from Kaggle into `data/raw`.
4.  Unzip the dataset.

```bash
# Make sure your kaggle.json is in the kaggle/ directory first!
bash setup.sh
```

### Step 4: Run the Notebooks in Order
Open the `notebooks/` directory and run the Jupyter notebooks sequentially:
1.  **Run `00_Setup_and_Data_Preparation.ipynb`** to process the data.
2.  **Run `01_Model_Training_Tournament.ipynb`** to train the models. This is computationally intensive and may take a significant amount of time.
3.  **Run `02_Analysis_and_Publication_Results.ipynb`** to generate all the final figures and analyses.

After running these notebooks, the `reports/` directory will be fully populated with the results documented in our paper.
