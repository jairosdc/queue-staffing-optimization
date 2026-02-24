import json

def get_cell_44():
    with open('Analisis_de_dataset.ipynb', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Try finding cell with execution_count == 44
    for i, cell in enumerate(data.get('cells', [])):
        if cell.get('cell_type') == 'code' and cell.get('execution_count') == 44:
            print(f"Found Code Cell with execution_count=44 at index {i}")
            print("".join(cell.get('source', [])))
            return
            
    # Or cell index 44
    if len(data.get('cells', [])) > 44:
        print("Found Cell at index 44:")
        print("".join(data['cells'][44].get('source', [])))
        return
        
get_cell_44()
