import json

with open('Analisis_de_dataset.ipynb', 'r', encoding='utf-8') as f:
    data = json.load(f)

with open('cell_44.py', 'w', encoding='utf-8') as out:
    # also print all cell execution_counts to see that
    counts = [c.get('execution_count') for c in data.get('cells', []) if c.get('cell_type') == 'code']
    out.write(f"# All code execution counts: {counts}\n\n")

    cells = data.get('cells', [])
    if len(cells) > 44:
        cell44 = cells[44]
        out.write("# CELL INDEX 44 CONTENT:\n")
        out.write("".join(cell44.get('source', [])))
        out.write("\n\n")
    else:
        out.write("# No cell at index 44\n\n")
        
    for i, c in enumerate(cells):
        if c.get('execution_count') == 44:
            out.write(f"# CELL WITH EXECUTION COUNT 44 (Index {i}):\n")
            out.write("".join(c.get('source', [])))
            out.write("\n\n")

print("Done extracting")
