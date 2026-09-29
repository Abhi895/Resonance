import coremltools as ct
import librosa
import numpy as np
import json
import os

def classify_audio(songPath, model, outputJSON):
    y, sr = librosa.load(songPath, sr=16000)
    duration = librosa.get_duration(y=y, sr=sr)

    predictions = []
    windowSize = 3.0
    stride = 0.5
    expectedSamples = int(windowSize * sr)

    for start in np.arange(0, duration - windowSize, stride):
        startSample = int(start * sr)
        endSample = startSample + expectedSamples

        chunk = y[startSample:endSample]

        if len(chunk) < expectedSamples:
            chunk = np.pad(chunk, (0, expectedSamples - len(chunk)))

        chunk = y[startSample:endSample]
        
        result = model.predict({'audioSamples': chunk})
        # print(result)
        predictions.append({
            "time": round(float(start), 2),
            "mood": result['target'],
            "confidence": max(result['targetProbability'].values())
        })

    with open(outputJSON, 'w') as f:
        json.dump(predictions, f, indent=2)
    # return predictions


vibeModel = ct.models.MLModel('VibeClassifier.mlmodel')
# print(vibeModel.input_description)
songs = [
    {
        'name': 'rock',
        'songPath': 'rock.wav',
    },
    {
        'name': 'acoustic',
        'songPath': 'acoustic.wav',
    },
    {
        'name': 'edm',
        'songPath': 'edm.wav',
    },
]

os.makedirs('data/vibes', exist_ok=True)


for song in songs:
    classify_audio(song['songPath'], vibeModel, f"data/vibes/{song['name']}_vibes.json")
