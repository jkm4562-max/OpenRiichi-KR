OpenRiichi 한국어 초보교실 교육 레이어 v0.1

기준 프로젝트: FluffyStuff/OpenRiichi
방식: 마작 룰/AI/점수 판정은 OpenRiichi 원본을 사용하고 GameMenuView의 UI/교육 설명만 교체합니다.

핵심:
- 치/퐁/깡/론/쯔모/리치 가능 여부를 자체 계산하지 않습니다.
- ClientRoundState -> GameMenuView로 전달되는 원본 enabled 신호만 사용합니다.
- 따라서 자패 퐁, 치 방향, 후리텐, 역 유무, 패산/유국 등 룰 판정은 OpenRiichi 쪽 책임입니다.
- 행동 버튼을 누르면 원래 signal(chii_pressed 등)을 그대로 호출하므로 실제 행동 경로도 원본과 동일합니다.

현재 검증 상태:
- 원본 GameController 연결 구조 대조 완료.
- ClientRoundState의 do_turn_decision / do_call_decision 대조 완료.
- GameMenuView signal 이름 및 setter API 대조 완료.
- 교육 레이어가 별도 룰 판정을 만들지 않는지 정적 검사 포함.
- 이 환경에는 valac/meson/Windows MinGW가 없어 실제 Windows 바이너리 컴파일 검증은 미완료입니다.

LICENSE:
원본 OpenRiichi 및 Engine의 라이선스를 따라야 합니다. 재배포 시 원본 LICENSE와 소스 제공 의무를 확인하세요.
