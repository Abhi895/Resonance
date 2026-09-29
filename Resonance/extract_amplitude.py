import librosa
import os
import json
import numpy as np

def extractAmplitude(audio, sampleRate, hopLength=512):
    rms = librosa.feature.rms(y=audio, hop_length=hopLength)[0]
    times = librosa.frames_to_time(
        np.arange(len(rms)), 
        sr=sampleRate, 
        hop_length=hopLength
    )
    
    return times, rms

def extractFromStem(stem, sampleRate, outputJSON):
    times, rms = extractAmplitude(stem, sampleRate)
    
    # Build JSON structure
    data = [
    {
        'time': round(float(t), 3),
        'amplitude': round(float(a), 4)
    }
    for t, a in zip(times, rms)
    ]
    
    with open(outputJSON, 'w') as f:
        json.dump(data, f, indent=2)


def merge_audio_data(song_name):
    # Load the three separate files
    with open(f'data/kicks/{song_name}_kicks.json') as f: kicks = json.load(f)
    with open(f'data/instruments/{song_name}_instruments.json') as f: insts = json.load(f)
    with open(f'data/vocals/{song_name}_vocals.json') as f: vocals = json.load(f)

    merged = []
    # Assuming all files have the same timestamps
    for k, i, v in zip(kicks, insts, vocals):
        merged.append({
            "t": k['time'],
            "k": k['amplitude'],
            "i": i['amplitude'],
            "v": v['amplitude']
        })

    with open(f'{song_name}.json', 'w') as f:
        json.dump(merged, f, indent=2)


#Main
songs = [
    {
        'name': 'rock',
        'vocals': 'stems/vocals.wav',
        'instruments': 'stems/other.wav'
    },
    {
        'name': 'acoustic',
        'vocals': 'stems/vocals (1).wav',
        'instruments': 'stems/other (1).wav'
    },
    {
        'name': 'edm',
        'vocals': 'stems/vocals (2).wav',
        'instruments': 'stems/other (2).wav'
    },

    {
        'name': 'tutorial',
        'vocals': 'stems/vocals (3).wav',
        'instruments': 'stems/other (3).wav',
        'kicks': 'stems/drums (3).wav'
    }
]

# Create output directory
os.makedirs('data/vocals', exist_ok=True)
os.makedirs('data/instruments', exist_ok=True)
os.makedirs('data/kicks', exist_ok=True)

for song in songs:
     vocals, sr = librosa.load(song['vocals'], sr=22050, mono=True)
     instruments, _ = librosa.load(song['instruments'], sr=22050, mono=True)
     if song['name'] == 'tutorial':
         kicks, _ = librosa.load(song['kicks'], sr=22050, mono=True)
         extractFromStem(
             stem=kicks,
             sampleRate=sr,
             outputJSON=f"data/kicks/{song['name']}_kicks.json",
         )   
        
     extractFromStem(
         stem=vocals,
         sampleRate=sr,
         outputJSON=f"data/vocals/{song['name']}_vocals.json",
     )
     extractFromStem(
         stem=instruments,
         sampleRate=sr,
         outputJSON=f"data/instruments/{song['name']}_instruments.json",
     )


merge_audio_data('edm')
merge_audio_data('rock')
merge_audio_data('acoustic')
merge_audio_data('tutorial')
