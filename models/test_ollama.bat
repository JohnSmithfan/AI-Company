@echo off
REM Test Ollama Adapter on Windows
REM Usage: test_ollama.bat

echo ============================================
echo Ollama Adapter Test (Windows)
echo ============================================

REM Check if Ollama is running
echo.
echo [1/3] Checking Ollama connection...
curl -s http://localhost:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo ✗ Ollama is not running
    echo   Please start Ollama with: ollama serve
    pause
    exit /b 1
) else (
    echo ✓ Ollama is running
)

REM Check Python
echo.
echo [2/3] Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ✗ Python not found
    echo   Please install Python 3.7+
    pause
    exit /b 1
) else (
    python --version
)

REM Install dependencies if needed
echo.
echo [3/3] Checking dependencies...
python -c "import openai" >nul 2>&1
if errorlevel 1 (
    echo   Installing openai package...
    pip install openai requests
)

REM Run test
echo.
echo ============================================
echo Running Ollama Adapter Test...
echo ============================================
python "%~dp0test_ollama.py"

if errorlevel 1 (
    echo.
    echo ✗ Some tests failed
    pause
    exit /b 1
) else (
    echo.
    echo ✓ All tests passed
    pause
    exit /b 0
)
