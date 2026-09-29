from scipy.signal import butter, filtfilt
import librosa
import soundfile as sf
import numpy as np
import json
import os

def designLowpassFilter(cutoffHz, sampleRate, order=4):
    nyquist = sampleRate / 2.0
    normlisedCutoff = cutoffHz / nyquist

    b, a = butter(order, normlisedCutoff, btype="low", analog=False)

    return b, a

def applyFilter(audio, b, a):
    filtered_audio = filtfilt(b, a, audio)

    return filtered_audio

def extractAmplitude(audio, sampleRate, hopLength=512):
    rms = librosa.feature.rms(y=audio, hop_length=hopLength)[0]
    
    # Convert frame indices to time
    # frames_to_time handles sample rate conversion
    times = librosa.frames_to_time(
        np.arange(len(rms)), 
        sr=sampleRate, 
        hop_length=hopLength
    )
    
    return times, rms

def extractKickFromStem(drumsPath, outputJSON, cutoffHz=150, saveFilteredAudio=False):


    # Load drums stem
    drums, sr = librosa.load(drumsPath, sr=22050, mono=True)
        
    # Design low-pass filter
    b, a = designLowpassFilter(cutoffHz, sr, order=4)
    
    # Apply filter
    filtered = applyFilter(drums, b, a)
    
    if saveFilteredAudio:
        filtered_path = outputJSON.replace('.json', '_filtered.wav')
        sf.write(filtered_path, filtered, sr)

    # Extract RMS amplitude
    times, rms = extractAmplitude(filtered, sr, hopLength=512)

    # Build JSON structure
    data = [
        {
            'time': round(float(t), 3),
            'amplitude': round(float(a), 4)
        }
        for t, a in zip(times, rms)
    ]
    
    #  Save JSON
    with open(outputJSON, 'w') as f:
        json.dump(data, f, indent=2)


# MAIN
cutoffFrequency = 150
saveFilteredWav = True

# Define your songs
songs = [
    {
        'name': 'rock',
        'drums': 'stems/drums.wav',
    },
    {
        'name': 'acoustic',
        'drums': 'stems/drums (1).wav',
    },
    {
        'name': 'edm',
        'drums': 'stems/drums (2).wav',
    },
]

# Create output directory
os.makedirs('data/kicks', exist_ok=True)

# Process each song
for song in songs:
    extractKickFromStem(
        drumsPath=song['drums'],
        outputJSON=f"data/kicks/{song['name']}_kicks.json",
        cutoffHz=cutoffFrequency,
        saveFilteredAudio=saveFilteredWav
    )
