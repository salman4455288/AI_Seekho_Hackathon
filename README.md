# AI Seekho Hackathon

## Overview

**AI_Seekho_Hackathon** is a curated collection of resources, code, and datasets designed for participating in AI hackathons focused on Urdu language processing and speech AI. The repository contains:

- **Data preprocessing scripts** for Urdu speech datasets.
- **Model training pipelines** leveraging state‑of‑the‑art speech‑to‑text architectures.
- **Evaluation notebooks** that benchmark model performance on standard Urdu speech corpora.
- **Utility tools** for visualising audio waveforms, spectrograms and transcription results.

The goal is to provide a ready‑to‑run foundation that participants can extend, experiment with, and adapt for their hackathon submissions.

---

## Table of Contents

1. [Project Structure](#project-structure)
2. [Setup & Installation](#setup--installation)
3. [Data Preparation](#data-preparation)
4. [Training & Evaluation](#training--evaluation)
5. [Usage Examples](#usage-examples)
6. [Contributing](#contributing)
7. [License](#license)
8. [Acknowledgements](#acknowledgements)

---

## Project Structure

```text
AI_Seekho_Hackathon/
│
├─ data/                 # Sample Urdu speech datasets & manifests
├─ notebooks/            # Jupyter notebooks for exploration & analysis
├─ src/                  # Core source code
│   ├─ models/           # Model definitions & wrappers
│   ├─ preprocessing/    # Audio preprocessing utilities
│   └─ utils/            # Helper functions (logging, metrics, etc.)
├─ scripts/              # CLI scripts for training, inference and evaluation
├─ requirements.txt      # Python dependencies
├─ environment.yml       # Conda environment file (optional)
└─ README.md             # This documentation
```

---

## Setup & Installation

> **Prerequisites**
> - Python 3.10 or newer
> - Git
> - `ffmpeg` (for audio handling)
> - CUDA‑enabled GPU (optional but recommended for faster training)

### 1. Clone the repository (already done)
```bash
# Already cloned to C:/Users/HP/OneDrive/Documents/AI_Seekho_Hackathon
```

### 2. Create a virtual environment and install dependencies
```bash
# Using conda (recommended)
conda env create -f environment.yml
conda activate ai_seekho

# Or using pip
python -m venv .venv
source .venv/bin/activate   # on Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Verify the installation
```bash
python -c "import src; print('Import successful!')"
```

---

## Data Preparation

1. Place your raw Urdu audio files (`.wav` or `.mp3`) inside `data/raw/`.
2. Run the preprocessing script to generate normalized spectrograms and accompanying transcription files:
```bash
python scripts/preprocess.py --input data/raw/ --output data/processed/
```
3. The script creates a `manifest.json` that can be directly fed to the training pipeline.

---

## Training & Evaluation

### Training
```bash
python scripts/train.py \
    --config configs/train.yaml \
    --data-dir data/processed/ \
    --output-dir outputs/
```
- **Configurable options** are defined in `configs/train.yaml` (learning rate, batch size, model architecture, etc.).

### Evaluation
```bash
python scripts/evaluate.py \
    --model outputs/best_model.pth \
    --data-dir data/processed/ \
    --metrics wer cer
```
- The script reports Word Error Rate (WER) and Character Error Rate (CER) on the validation set.

---

## Usage Examples

Below is a quick example of loading a trained model and transcribing a single audio file:

```python
from src.models import SpeechRecognizer
from src.utils.audio import load_audio

model = SpeechRecognizer.load('outputs/best_model.pth')
audio = load_audio('data/raw/example.wav')
transcript = model.transcribe(audio)
print('Transcription:', transcript)
```

---

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository.
2. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes, ensuring code style compliance (`black`, `flake8`).
4. Write or update tests in the `tests/` directory.
5. Commit with clear messages and push:
   ```bash
   git commit -m "feat: brief description"
   git push origin feature/your-feature-name
   ```
6. Open a Pull Request against the `main` branch.

Please refer to the `CONTRIBUTING.md` file (to be added) for detailed guidelines.

---

## License

This project is licensed under the **MIT License** – see the `LICENSE` file for details.

---

## Acknowledgements

- **Hugging Face Transformers** for the underlying speech model architectures.
- **OpenAI Whisper** for inspiration on multilingual speech recognition.
- The Urdu language community for providing open datasets.

---

*Happy hacking! 🚀*
