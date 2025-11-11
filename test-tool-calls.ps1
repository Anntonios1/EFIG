# Test de Tool Calls en Copilot API
Write-Host "🔧 Testeando Tool Calls en Copilot API..." -ForegroundColor Cyan

Start-Sleep -Seconds 3

$body = @{
    model = "gpt-4"
    messages = @(
        @{
            role = "user"
            content = "What is the weather in New York?"
        }
    )
    tools = @(
        @{
            type = "function"
            function = @{
                name = "get_weather"
                description = "Get the current weather in a given location"
                parameters = @{
                    type = "object"
                    properties = @{
                        location = @{
                            type = "string"
                            description = "The city and state, e.g. San Francisco, CA"
                        }
                        unit = @{
                            type = "string"
                            enum = @("celsius", "fahrenheit")
                        }
                    }
                    required = @("location")
                }
            }
        }
    )
    temperature = 0.7
    max_tokens = 500
    stream = $false
} | ConvertTo-Json -Depth 10

Write-Host "`n📤 Enviando request con tool..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "http://34.66.86.207:8002/v1/chat/completions" `
        -Method Post `
        -ContentType "application/json" `
        -Body $body

    Write-Host "`n✅ Respuesta recibida:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10 | Write-Host

    if ($response.choices[0].message.tool_calls) {
        Write-Host "`n🎉 ¡Tool calls detectados!" -ForegroundColor Green
        Write-Host "Tool: $($response.choices[0].message.tool_calls[0].function.name)" -ForegroundColor Cyan
        Write-Host "Arguments: $($response.choices[0].message.tool_calls[0].function.arguments)" -ForegroundColor Cyan
    } else {
        Write-Host "`n⚠️  No se detectaron tool calls en la respuesta" -ForegroundColor Yellow
        Write-Host "Content: $($response.choices[0].message.content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "`n❌ Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host $_.ErrorDetails.Message -ForegroundColor Red
    }
}
