Write-Output 'Install packages...'
npm ci

Write-Output 'Build application...'
npm run build

Write-Output 'Run tests...'
npm test --if-present
