# Скрипт проверки работоспособности развернутого приложения
param(
    [Parameter(Mandatory=$true)]
    [string]$FrontendUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$BackendUrl
)

Write-Host "🧪 Проверка работоспособности приложения на Azure" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

Write-Host "🌐 Frontend URL: $FrontendUrl" -ForegroundColor Cyan
Write-Host "⚙️ Backend URL: $BackendUrl" -ForegroundColor Cyan

# Функция для проверки URL
function Test-Url {
    param(
        [string]$Url,
        [string]$Name,
        [int]$TimeoutSeconds = 30
    )
    
    Write-Host "🔍 Проверка $Name..." -ForegroundColor Yellow
    
    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec $TimeoutSeconds -UseBasicParsing
        $stopwatch.Stop()
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $Name доступен (Время ответа: $($stopwatch.ElapsedMilliseconds)мс)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $Name недоступен (Статус: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ $Name недоступен (Ошибка: $($_.Exception.Message))" -ForegroundColor Red
        return $false
    }
}

# Функция для проверки API эндпоинтов
function Test-ApiEndpoints {
    param(
        [string]$BaseUrl
    )
    
    Write-Host "🔍 Проверка API эндпоинтов..." -ForegroundColor Yellow
    
    $endpoints = @(
        "$BaseUrl/api/chat/messages",
        "$BaseUrl/swagger"
    )
    
    $successCount = 0
    
    foreach ($endpoint in $endpoints) {
        try {
            $response = Invoke-WebRequest -Uri $endpoint -TimeoutSec 10 -UseBasicParsing
            if ($response.StatusCode -eq 200) {
                Write-Host "✅ $($endpoint.Split('/')[-1]) доступен" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "❌ $($endpoint.Split('/')[-1]) недоступен" -ForegroundColor Red
            }
        } catch {
            Write-Host "❌ $($endpoint.Split('/')[-1]) недоступен" -ForegroundColor Red
        }
    }
    
    return $successCount -eq $endpoints.Count
}

# Функция для тестирования отправки сообщения
function Test-MessageSending {
    param(
        [string]$BaseUrl
    )
    
    Write-Host "🔍 Тестирование отправки сообщения..." -ForegroundColor Yellow
    
    try {
        $messageData = @{
            User = "TestUser"
            Text = "Test message from deployment check"
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BaseUrl/api/chat/send" -Method Post -Body $messageData -ContentType "application/json" -TimeoutSec 10
        
        if ($response -and $response.User -eq "TestUser") {
            Write-Host "✅ Отправка сообщения работает" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Отправка сообщения не работает" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ Отправка сообщения не работает (Ошибка: $($_.Exception.Message))" -ForegroundColor Red
        return $false
    }
}

# Основная проверка
Write-Host ""
Write-Host "🚀 Начало проверки..." -ForegroundColor Yellow

# Проверка доступности фронтенда
$frontendOk = Test-Url -Url $FrontendUrl -Name "Frontend"

# Проверка доступности бэкенда
$backendOk = Test-Url -Url $BackendUrl -Name "Backend"

# Проверка API эндпоинтов
$apiOk = Test-ApiEndpoints -BaseUrl $BackendUrl

# Тестирование функциональности
$messageTestOk = Test-MessageSending -BaseUrl $BackendUrl

Write-Host ""
Write-Host "📊 Результаты проверки:" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

$allTests = @(
    @{ Name = "Frontend"; Status = $frontendOk },
    @{ Name = "Backend"; Status = $backendOk },
    @{ Name = "API Endpoints"; Status = $apiOk },
    @{ Name = "Message Sending"; Status = $messageTestOk }
)

foreach ($test in $allTests) {
    $status = if ($test.Status) { "✅ PASS" } else { "❌ FAIL" }
    $color = if ($test.Status) { "Green" } else { "Red" }
    Write-Host "$($test.Name): $status" -ForegroundColor $color
}

$overallSuccess = $frontendOk -and $backendOk -and $apiOk -and $messageTestOk

Write-Host ""
if ($overallSuccess) {
    Write-Host "🎉 Все тесты пройдены! Приложение работает корректно!" -ForegroundColor Green
    Write-Host "🌐 Приложение доступно по адресу: $FrontendUrl" -ForegroundColor Cyan
} else {
    Write-Host "⚠️ Некоторые тесты не пройдены. Проверьте логи развертывания." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📖 Дополнительная информация:" -ForegroundColor Yellow
Write-Host "🔧 Swagger документация: $BackendUrl/swagger" -ForegroundColor Cyan
Write-Host "📊 SignalR соединения проверяются в реальном времени" -ForegroundColor Cyan
Write-Host "🧠 Sentiment Analysis работает через Azure Cognitive Services" -ForegroundColor Cyan

return $overallSuccess
