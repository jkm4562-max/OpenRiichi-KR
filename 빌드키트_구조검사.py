from pathlib import Path
p=Path(__file__).resolve().parent
req=[
 p/'.github/workflows/build-windows.yml',
 p/'patch/source/Game/Rendering/Menu/GameMenuView.vala',
 p/'patch/README_KR.txt',
 p/'처음읽어주세요.txt'
]
bad=[str(x) for x in req if not x.exists()]
if bad:
    raise SystemExit("누락: "+", ".join(bad))
w=(p/'.github/workflows/build-windows.yml').read_text(encoding='utf-8')
for s in ['clone --recurse-submodules','meson setup','meson compile','OpenRiichi.exe','upload-artifact@v4']:
    assert s in w, s
print("빌드 키트 구조 검사 통과")
