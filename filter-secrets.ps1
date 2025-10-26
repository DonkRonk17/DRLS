$file = "Instruction Overview w Grok.txt"
if (Test-Path $file) {
    $content = Get-Content $file -Raw
    $content = $content -replace 'YOUR_XAI_API_KEY_HERE', 'YOUR_XAI_API_KEY_HERE'
    Set-Content $file -Value $content -NoNewline
}
