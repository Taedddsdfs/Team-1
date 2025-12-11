import numpy as np
import matplotlib.pyplot as plt
import os

# --- Configuration ---
# List of filenames expected in the repository
MEM_FILES = {
    'gaussian': 'gaussian.mem',
    'noisy': 'noisy.mem',     
    'triangle': 'triangle.mem',
    'sine': 'sine.mem'        
}

def load_mem_file(filename):
    """
    Reads a .mem file typically used in Verilog $readmemh.
    Parses Hexadecimal strings into an integer array.
    """
    data = []
    
    
    if not os.path.exists(filename):
        print(f"[Warning] File '{filename}' not found locally. Using synthetic data instead.")
        return None

    try:
        with open(filename, 'r') as f:
            lines = f.readlines()
            for line in lines:
               
                clean_line = line.split('//')[0].strip()
                if not clean_line:
                    continue
                
                
                if clean_line.startswith('@'):
                    continue
                
        
                parts = clean_line.split()
                for part in parts:
                    try:
                      
                        val = int(part, 16)
                        data.append(val)
                    except ValueError:
                        continue
                        
        print(f"[Success] Loaded {len(data)} samples from '{filename}'.")
        return np.array(data)
        
    except Exception as e:
        print(f"[Error] Failed to read '{filename}': {e}")
        return None

def generate_synthetic_data(key):
   
    N = 20000
    if key == 'gaussian': return np.clip(np.random.normal(128, 40, N), 0, 255).astype(int)
    if key == 'triangle': return np.clip(np.random.uniform(0, 256, N), 0, 255).astype(int) # Approx
    if key == 'sine': return (127.5 * np.sin(np.linspace(0, 100, N)) + 127.5).astype(int)
    return np.random.randint(0, 256, N) # Default noisy

def run_reference_logic(data):

    pdf = np.zeros(256, dtype=int)
    max_count = 200
    processed_count = 0
    
    for val in data:
        # Ensure value is within byte range (safety check)
        val = val & 0xFF 
        
        processed_count += 1
        pdf[val] += 1
        
        if pdf[val] == max_count:
            break
            
    return pdf, processed_count

def main():
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Reference Program Evidence (Parsed from .mem files)", fontsize=16)
    axes = axes.flatten()
    
    plot_keys = list(MEM_FILES.keys())
    
    for i, key in enumerate(plot_keys):
        filename = MEM_FILES[key]
        
        data = load_mem_file(filename)
        is_synthetic = False
        
        if data is None or len(data) == 0:
            data = generate_synthetic_data(key)
            is_synthetic = True
            
    
        pdf_res, samples = run_reference_logic(data)
        
        # 3. Plot
        ax = axes[i]
        color = '#d62728' if is_synthetic else '#1f77b4' # Red if fake, Blue if real
        ax.bar(range(256), pdf_res, color=color, width=1.0)
        
        # Labels
        title_prefix = "[SYNTHETIC] " if is_synthetic else "[REAL FILE] "
        ax.set_title(f"{title_prefix}{key.capitalize()} Distribution", fontsize=12, fontweight='bold')
        ax.set_xlim(0, 255)
        ax.set_ylim(0, 220)
        ax.axhline(200, color='black', linestyle='--', linewidth=1, alpha=0.5, label='Max Count (200)')
        
        # Stats
        stats = f"Samples: {samples}\nPeak: {np.max(pdf_res)}"
        ax.text(0.05, 0.85, stats, transform=ax.transAxes, 
                bbox=dict(facecolor='white', alpha=0.9), fontsize=9)
        
        if i == 0: ax.legend(loc='upper right')

    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    plt.savefig("final_evidence_from_mem.png")
    print("\n[Done] Evidence image saved as 'final_evidence_from_mem.png'")
    plt.show()

if _name_ == "_main_":
    main()
