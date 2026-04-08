using backend_wasm.Application.Interfaces;
using backend_wasm.WebApi.Hubs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace backend_wasm.WebApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ChatController : ControllerBase
{
    private readonly IChatService _chatService;
    private readonly IHubContext<ChatHub> _hub;
    private readonly ILogger<ChatController> _logger;

    public ChatController(IChatService chatService, IHubContext<ChatHub> hub, ILogger<ChatController> logger)
    {
        _chatService = chatService;
        _hub = hub;
        _logger = logger;
    }

    [HttpPost("send")]
    public async Task<IActionResult> SendMessage([FromBody] ChatRequest request)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(request.User) || string.IsNullOrWhiteSpace(request.Text))
            {
                return BadRequest("User and text are required");
            }

            var msg = await _chatService.ProcessMessageAsync(request.User, request.Text);

            await _hub.Clients.All.SendAsync("ReceiveMessage", new
            {
                Id = msg.Id,
                User = msg.User,
                Text = msg.Text,
                Sentiment = msg.Sentiment,
                PositiveScore = msg.PositiveScore,
                NegativeScore = msg.NegativeScore,
                Timestamp = msg.Timestamp
            });

            _logger.LogInformation("Message from {User} broadcasted successfully", request.User);
            return Ok(msg);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending message from {User}", request.User);
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("messages")]
    public async Task<IActionResult> GetMessages([FromQuery] int count = 50)
    {
        try
        {
            var messages = await _chatService.GetRecentMessagesAsync(count);
            return Ok(messages);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving messages");
            return StatusCode(500, "Internal server error");
        }
    }
}

public record ChatRequest(string User, string Text);
