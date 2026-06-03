@echo off

start "Backend" cmd /k "backend\start_backend.bat"
start "Frontend" cmd /k "frontend\start_frontend.bat"

exit