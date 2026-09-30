from pathlib import Path
p=Path('source/Game/Rendering/Menu/GameMenuView.vala')
s=p.read_text(encoding='utf-8')
checks={
'원본 행동 signal 유지': all(x in s for x in ['chii_pressed();','pon_pressed();','kan_pressed();','riichi_pressed(false);','tsumo_pressed();','ron_pressed();','continue_pressed();']),
'교육 레이어 자체 can_chii 없음': 'can_chii' not in s,
'교육 레이어 자체 can_pon 없음': 'can_pon' not in s,
'교육 레이어 자체 can_ron 없음': 'can_ron' not in s,
'교육 레이어 자체 can_tsumo 없음': 'can_tsumo' not in s,
'한국어 치 설명': '치(Chii)' in s,
'자패 퐁 설명': '자패도 퐁할 수 있어' in s,
'후리텐 설명': '후리텐 상태야' in s,
'리치 설명': '리치(Riichi)' in s,
'엔진 판정 안내': '엔진의 합법 행동 판정' in s,
}
for k,v in checks.items(): print(('PASS' if v else 'FAIL'), k)
if not all(checks.values()): raise SystemExit(1)
print(f'PASS {sum(checks.values())}/{len(checks)}')
