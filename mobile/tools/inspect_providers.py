from pathlib import Path
import re

root = Path(r'C:\laragon\www\rfid\mobile')

# Show current provider wiring
for p in sorted((root/'lib/features').glob('**/providers/*_providers.dart')):
    text = p.read_text(encoding='utf-8')
    print('\n==', p.relative_to(root))
    for i, line in enumerate(text.splitlines(), 1):
        if 'return ' in line and ('Repository' in line or 'Mock' in line or 'Local' in line or 'Remote' in line):
            print(f'{i}: {line.rstrip()}')
