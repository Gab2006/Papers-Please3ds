import re

with open('scratch_truth.html', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

print('Length:', len(text))
links = re.findall(r'https?://[^\s"\'<>]+\.(?:png|jpg|jpeg)', text)
for link in list(dict.fromkeys(links))[:20]:
    print(link)
