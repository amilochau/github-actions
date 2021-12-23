Write-Output '=========='
Write-Output 'Install packages...'
npm ci

Write-Output '=========='
Write-Output 'Build application...'
npm run build

Write-Output '=========='
Write-Output 'Run tests...'
npm test --if-present

Write-Output '=========='
