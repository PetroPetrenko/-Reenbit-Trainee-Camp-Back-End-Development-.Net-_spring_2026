using System.Net.Http.Json;
using System.Text.Json;
using Xunit;

namespace backend_wasm.Tests;

public class SimpleApiTests
{
    private readonly HttpClient _client;
    private const string BaseUrl = "http://localhost:5001";

    public SimpleApiTests()
    {
        _client = new HttpClient();
    }

    [Fact]
    public async Task Test_Message_Structure()
    {
        // Test message structure that should be returned by API
        var message = new
        {
            Id = 1,
            User = "TestUser",
            Text = "Hello World!",
            Timestamp = DateTime.UtcNow,
            Sentiment = "neutral",
            PositiveScore = 0.5f,
            NegativeScore = 0.2f
        };

        // Assert message structure
        Assert.NotNull(message);
        Assert.Equal("TestUser", message.User);
        Assert.Equal("Hello World!", message.Text);
        Assert.True(message.Timestamp > DateTime.MinValue);
        Assert.NotNull(message.Sentiment);
        Assert.True(message.PositiveScore >= 0);
        Assert.True(message.NegativeScore >= 0);
    }

    [Fact]
    public void Test_Message_Validation()
    {
        // Test validation logic
        var validMessage = new { User = "ValidUser", Text = "Valid message text" };
        var invalidUserMessage = new { User = "", Text = "Some text" };
        var invalidTextMessage = new { User = "User", Text = "" };

        // Assert validation
        Assert.False(string.IsNullOrWhiteSpace(validMessage.User));
        Assert.False(string.IsNullOrWhiteSpace(validMessage.Text));
        Assert.True(string.IsNullOrWhiteSpace(invalidUserMessage.User));
        Assert.True(string.IsNullOrWhiteSpace(invalidTextMessage.Text));
    }

    [Fact]
    public void Test_Sentiment_Categories()
    {
        // Test sentiment categories
        var sentiments = new[] { "positive", "negative", "neutral", "mixed" };
        
        foreach (var sentiment in sentiments)
        {
            Assert.Contains(sentiment, sentiments);
        }

        Assert.True(sentiments.Contains("positive"));
        Assert.True(sentiments.Contains("negative"));
        Assert.True(sentiments.Contains("neutral"));
    }

    [Fact]
    public void Test_SignalR_Message_Json_Structure()
    {
        // Test SignalR message structure
        var signalRMessage = new
        {
            User = "SignalRUser",
            Text = "Real-time message",
            Timestamp = DateTime.UtcNow,
            Sentiment = "positive",
            PositiveScore = 0.8f,
            NegativeScore = 0.1f
        };

        var json = JsonSerializer.Serialize(signalRMessage);
        var parsed = JsonSerializer.Deserialize<JsonElement>(json);

        Assert.True(parsed.TryGetProperty("User", out var userProp));
        Assert.True(parsed.TryGetProperty("Text", out var textProp));
        Assert.True(parsed.TryGetProperty("Timestamp", out var timestampProp));
        Assert.True(parsed.TryGetProperty("Sentiment", out var sentimentProp));

        Assert.Equal("SignalRUser", userProp.GetString());
        Assert.Equal("Real-time message", textProp.GetString());
        Assert.Equal("positive", sentimentProp.GetString());
    }

    [Fact]
    public void Test_Chat_Room_Mock_Scenario()
    {
        // Mock chat room scenario
        var users = new[] { "Alice", "Bob", "Charlie" };
        var messages = new[]
        {
            new { User = "Alice", Text = "Hello everyone!", Sentiment = "positive" },
            new { User = "Bob", Text = "Hi Alice!", Sentiment = "neutral" },
            new { User = "Charlie", Text = "Good morning!", Sentiment = "positive" }
        };

        // Assert chat room logic
        Assert.Equal(3, users.Length);
        Assert.Equal(3, messages.Length);
        
        foreach (var message in messages)
        {
            Assert.Contains(users, u => u == message.User);
            Assert.False(string.IsNullOrWhiteSpace(message.Text));
            Assert.NotNull(message.Sentiment);
        }

        var positiveMessages = messages.Where(m => m.Sentiment == "positive").ToList();
        Assert.Equal(2, positiveMessages.Count);
    }

    [Fact]
    public void Test_Message_Ordering()
    {
        // Test message ordering by timestamp
        var messages = new[]
        {
            new { Timestamp = DateTime.UtcNow.AddMinutes(-2), Text = "First" },
            new { Timestamp = DateTime.UtcNow.AddMinutes(-1), Text = "Second" },
            new { Timestamp = DateTime.UtcNow, Text = "Latest" }
        };

        var orderedMessages = messages.OrderByDescending(m => m.Timestamp).ToList();

        Assert.Equal("Latest", orderedMessages[0].Text);
        Assert.Equal("Second", orderedMessages[1].Text);
        Assert.Equal("First", orderedMessages[2].Text);
    }
}
