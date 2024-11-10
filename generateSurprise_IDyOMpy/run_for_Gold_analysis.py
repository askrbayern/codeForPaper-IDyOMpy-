# input file: four Gold_trained_on_mixed2.mat files
# output file: GoldReplication/all_vals_paper.mat

import scipy.io as sio
import numpy as np
import re
import os
from mido import MidiFile
from pathlib import Path

def get_note_lengths(midi_file):
    """
    get note lengths
    """
    mid = MidiFile(midi_file)
    note_lengths = []
    active_notes = {}
    for track in mid.tracks:
        # cumulative time in ticks
        time = 0
        for msg in track:
            if msg.type == 'note_on':
                if msg.velocity > 0: # means start
                    active_notes[msg.note] = time
                else:
                    # velocity =0, means end
                    if msg.note in active_notes:
                        start_time = active_notes.pop(msg.note)
                        note_lengths.append(time - start_time)
            # add delta time
            time += msg.time
    
    print(f"Found {len(note_lengths)} notes in {midi_file}")
    return np.array(note_lengths)

def process_gold_data(data, midi_data):
    """
    do duration weighted mean
    """
    gold_processed = {}
    for key in data.keys():
        if key == 'info' or key.startswith('__'):
            continue
        match = re.search(r'\d+', key)
        if match:
            number = int(match.group())
            field_data = data[key]
            gold_processed[number] = (field_data[0], field_data[1])
    
    # sort first by number
    sorted_data = sorted(gold_processed.items())
    ic = np.zeros((57, 1)) # 57 pieces
    entropy = np.zeros((57, 1)) # 57 pieces
    
    for idx, (number, (ic_data, entropy_data)) in enumerate(sorted_data):
        if number in midi_data:
            note_lengths = midi_data[number]
            
            # ensure arrays have same length
            # ensure all arrays have same length
            min_length = min(len(ic_data), len(entropy_data), len(note_lengths))
            assert len(ic_data) == len(entropy_data) == len(note_lengths), "Length between midi and IC/Entropy do not match"
            ic_data = ic_data[:min_length]
            entropy_data = entropy_data[:min_length]
            note_lengths = note_lengths[:min_length]
            
            # calculate duration weighted means
            total_duration = np.sum(note_lengths)
            weighted_ic = np.sum(ic_data * note_lengths) / total_duration
            weighted_entropy = np.sum(entropy_data * note_lengths) / total_duration
            
            ic[idx] = weighted_ic
            entropy[idx] = weighted_entropy
    
    return ic, entropy

def main():
    # this file is placed in IDyOMpy, so go up to reach codeForPaper
    parent_dir = Path.cwd().parent  
    ppm_dir = parent_dir / 'benchmark_results' / 'forBenchmark_idyompy_ppm'
    py_dir = parent_dir / 'benchmark_results' / 'forBenchmark_idyompy'
    lisp_dir = parent_dir / 'benchmark_results' / 'forBenchmark_lisp'
    genuine_dir = parent_dir / 'benchmark_results' / 'forBenchmark_idyompy_genuine'
    gold_dir = parent_dir / 'GoldReplication'
    stimuli_dir = parent_dir / 'stimuli' / 'Gold'
    
    print("Loading MIDI data...")
    midi_data = {}
    files_found = 0
    for filename in os.listdir(stimuli_dir):
        if filename.endswith(('.mid', '.midi')):
            match = re.search(r'^(\d+)', filename)
            if match:
                number = int(match.group(1))
                midi_path = stimuli_dir / filename
                note_lengths = get_note_lengths(str(midi_path))
                midi_data[number] = note_lengths
                files_found += 1
    
    if files_found != 57:
        raise ValueError(f"Expected 57 MIDI files but found {files_found}")
    
    # the same file exists in all four directories
    input_file = 'Gold_trained_on_mixed2.mat'
    output_file = gold_dir / 'all_vals_paper.mat'
    
    files_to_check = [
        ppm_dir / input_file,
        py_dir / input_file,
        lisp_dir / input_file,
        genuine_dir / input_file
    ]
    
    missing_files = [f for f in files_to_check if not f.exists()]
    if missing_files:
        print("Warning: The following files are missing:")
        for f in missing_files:
            print(f"- {f}")
        response = input("Do you want to continue? (Y/N): ")
        if response.upper() != 'Y':
            print("Operation cancelled.")
            return
    
    all_vals = {}

    # Python
    print("Processing Python implementation...")
    py_data = sio.loadmat(str(py_dir / input_file))
    py_ic, py_entropy = process_gold_data(py_data, midi_data)
    all_vals['approx_mDW_IC'] = py_ic
    all_vals['approx_mDW_Entropy'] = py_entropy
    
    # PPM
    print("Processing PPM implementation...")
    ppm_data = sio.loadmat(str(ppm_dir / input_file))
    ppm_ic, ppm_entropy = process_gold_data(ppm_data, midi_data)
    all_vals['ppm_mDW_IC'] = ppm_ic
    all_vals['ppm_mDW_Entropy'] = ppm_entropy
     
    # LISP
    print("Processing LISP implementation...")
    lisp_data = sio.loadmat(str(lisp_dir / input_file))
    lisp_ic, lisp_entropy = process_gold_data(lisp_data, midi_data)
    all_vals['bg_mDW_IC'] = lisp_ic
    all_vals['bg_mDW_Entropy'] = lisp_entropy
    
    # Genuine
    print("Processing Genuine implementation...")
    genuine_data = sio.loadmat(str(genuine_dir / input_file))
    genuine_ic, genuine_entropy = process_gold_data(genuine_data, midi_data)
    all_vals['genuine_mDW_IC'] = genuine_ic
    all_vals['genuine_mDW_Entropy'] = genuine_entropy
    
    # save
    print("Saving combined results...")
    sio.savemat(str(output_file), {'all_vals': all_vals})
    print(f"Results saved to: {output_file}")
    print("Finished processing.")

if __name__ == "__main__":
    main()