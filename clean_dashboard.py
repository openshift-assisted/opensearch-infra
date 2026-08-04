import json
import sys

file_path = "kibana/dashboards/[CI] Monthly overview.ndjson"

# Read all lines
with open(file_path, "r") as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if not line.strip():
        new_lines.append(line)
        continue
    
    obj = json.loads(line)
    
    # Remove Equinix visualizations
    if obj.get("type") == "visualization":
        title = obj.get("attributes", {}).get("title", "")
        if "equinix" in title.lower():
            continue  # Skip writing this visualization
            
    # Modify the dashboard object
    elif obj.get("type") == "dashboard":
        # Remove from references
        refs = obj.get("references", [])
        new_refs = [r for r in refs if r.get("name") not in ["panel_6", "panel_7", "panel_8", "panel_9", "panel_10"]]
        obj["references"] = new_refs
        
        # Remove from panelsJSON
        panels = json.loads(obj["attributes"]["panelsJSON"])
        new_panels = [p for p in panels if p.get("panelRefName") not in ["panel_6", "panel_7", "panel_8", "panel_9", "panel_10"]]
        obj["attributes"]["panelsJSON"] = json.dumps(new_panels, separators=(',', ':'))
        
        new_lines.append(json.dumps(obj, separators=(',', ':')) + "\n")
        continue

    new_lines.append(line)

with open(file_path, "w") as f:
    f.writelines(new_lines)
