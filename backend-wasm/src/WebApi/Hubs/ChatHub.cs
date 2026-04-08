using Microsoft.AspNetCore.SignalR;

namespace backend_wasm.WebApi.Hubs;

public class ChatHub : Hub
{
    public async Task JoinChat(string user)
    {
        await Clients.All.SendAsync("UserJoined", user);
    }

    public async Task LeaveChat(string user)
    {
        await Clients.All.SendAsync("UserLeft", user);
    }
}
