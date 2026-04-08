using Microsoft.AspNetCore.SignalR.Client;

namespace frontend_blazor_wasm.Services;

public class Message
{
    public int Id { get; set; }
    public string User { get; set; } = default!;
    public string Text { get; set; } = default!;
    public string Sentiment { get; set; } = default!;
    public float PositiveScore { get; set; }
    public float NegativeScore { get; set; }
    public DateTime Timestamp { get; set; }
}

public class ChatService
{
    private readonly HttpClient _http;
    private HubConnection? _hubConnection;

    public event Action<Message>? OnMessageReceived;
    public event Action<string>? OnUserJoined;
    public event Action<string>? OnUserLeft;

    public ChatService(HttpClient http)
    {
        _http = http;
        _hubConnection = new HubConnectionBuilder()
            .WithUrl(_http.BaseAddress + "chathub")
            .WithAutomaticReconnect()
            .Build();

        _hubConnection.On<Message>("ReceiveMessage", (msg) =>
        {
            OnMessageReceived?.Invoke(msg);
        });

        _hubConnection.On<string>("UserJoined", (user) =>
        {
            OnUserJoined?.Invoke(user);
        });

        _hubConnection.On<string>("UserLeft", (user) =>
        {
            OnUserLeft?.Invoke(user);
        });
    }

    public async Task StartAsync()
    {
        if (_hubConnection is not null)
        {
            await _hubConnection.StartAsync();
        }
    }

    public async Task StopAsync()
    {
        if (_hubConnection is not null)
        {
            await _hubConnection.StopAsync();
        }
    }

    public async Task SendMessageAsync(string user, string text)
    {
        var response = await _http.PostAsJsonAsync("/api/chat/send", new { User = user, Text = text });
        response.EnsureSuccessStatusCode();
    }

    public async Task<List<Message>> GetMessagesAsync(int count = 50)
    {
        return await _http.GetFromJsonAsync<List<Message>>($"/api/chat/messages?count={count}") 
               ?? new List<Message>();
    }

    public async Task JoinChatAsync(string user)
    {
        if (_hubConnection is not null)
        {
            await _hubConnection.InvokeAsync("JoinChat", user);
        }
    }

    public async Task LeaveChatAsync(string user)
    {
        if (_hubConnection is not null)
        {
            await _hubConnection.InvokeAsync("LeaveChat", user);
        }
    }
}
