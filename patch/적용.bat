@echo off
chcp 65001 >nul
set ROOT=%~dp0
if not exist "%ROOT%OpenRiichi\source\Game\Rendering\Menu\GameMenuView.vala" (
 echo [오류] 이 통합팩의 OpenRiichi 폴더가 없습니다.
 pause
 exit /b 1
)
copy /Y "%ROOT%source\Game\Rendering\Menu\GameMenuView.vala" "%ROOT%OpenRiichi\source\Game\Rendering\Menu\GameMenuView.vala" >nul
if errorlevel 1 (
 echo [오류] 교육 레이어 적용 실패
 pause
 exit /b 1
)
echo [완료] OpenRiichi 원본에 한국어 교육 레이어가 적용되었습니다.
pause
