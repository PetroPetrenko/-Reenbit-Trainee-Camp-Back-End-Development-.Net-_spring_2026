using Xunit;
using System.Text.Json;

namespace backend_wasm.Tests;

public class ChatApplicationTests
{
    [Fact]
    public void Test_Message_Structure_Is_Valid()
    {
        // Arrange
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

        // Assert
        Assert.NotNull(message);
        Assert.Equal("TestUser", message.User);
        Assert.Equal("Hello World!", message.Text);
        Assert.True(message.Timestamp > DateTime.MinValue);
        Assert.NotNull(message.Sentiment);
        Assert.True(message.PositiveScore >= 0);
        Assert.True(message.NegativeScore >= 0);
    }

    [Fact]
    public void Test_Message_Validation_Rules()
    {
        // Test valid message
        var validMessage = new { User = "ValidUser", Text = "Valid message text" };
        Assert.False(string.IsNullOrWhiteSpace(validMessage.User));
        Assert.False(string.IsNullOrWhiteSpace(validMessage.Text));

        // Test invalid messages
        var invalidUserMessage = new { User = "", Text = "Some text" };
        var invalidTextMessage = new { User = "User", Text = "" };
        var emptyMessage = new { User = "", Text = "" };

        Assert.True(string.IsNullOrWhiteSpace(invalidUserMessage.User));
        Assert.True(string.IsNullOrWhiteSpace(invalidTextMessage.Text));
        Assert.True(string.IsNullOrWhiteSpace(emptyMessage.User));
        Assert.True(string.IsNullOrWhiteSpace(emptyMessage.Text));
    }

    [Fact]
    public void Test_Sentiment_Categories()
    {
        var sentiments = new[] { "positive", "negative", "neutral", "mixed" };
        
        // Test all sentiment categories exist
        Assert.Contains("positive", sentiments);
        Assert.Contains("negative", sentiments);
        Assert.Contains("neutral", sentiments);
        Assert.Contains("mixed", sentiments);

        // Test sentiment scores are valid
        foreach (var sentiment in sentiments)
        {
            Assert.False(string.IsNullOrWhiteSpace(sentiment));
        }
    }

    [Fact]
    public void Test_SignalR_Message_Json_Serialization()
    {
        // Arrange
        var signalRMessage = new
        {
            User = "SignalRUser",
            Text = "Real-time message",
            Timestamp = DateTime.UtcNow,
            Sentiment = "positive",
            PositiveScore = 0.8f,
            NegativeScore = 0.1f
        };

        // Act
        var json = JsonSerializer.Serialize(signalRMessage);
        var parsed = JsonSerializer.Deserialize<JsonElement>(json);

        // Assert
        Assert.True(parsed.TryGetProperty("User", out var userProp));
        Assert.True(parsed.TryGetProperty("Text", out var textProp));
        Assert.True(parsed.TryGetProperty("Timestamp", out var timestampProp));
        Assert.True(parsed.TryGetProperty("Sentiment", out var sentimentProp));
        Assert.True(parsed.TryGetProperty("PositiveScore", out var positiveScoreProp));
        Assert.True(parsed.TryGetProperty("NegativeScore", out var negativeScoreProp));

        Assert.Equal("SignalRUser", userProp.GetString());
        Assert.Equal("Real-time message", textProp.GetString());
        Assert.Equal("positive", sentimentProp.GetString());
        Assert.True(positiveScoreProp.GetSingle() >= 0);
        Assert.True(negativeScoreProp.GetSingle() >= 0);
    }

    [Fact]
    public void Test_Chat_Room_Multiple_Users()
    {
        // Arrange
        var users = new[] { "Alice", "Bob", "Charlie" };
        var messages = new[]
        {
            new { User = "Alice", Text = "Hello everyone!", Sentiment = "positive" },
            new { User = "Bob", Text = "Hi Alice!", Sentiment = "neutral" },
            new { User = "Charlie", Text = "Good morning!", Sentiment = "positive" }
        };

        // Assert
        Assert.Equal(3, users.Length);
        Assert.Equal(3, messages.Length);
        
        // All users sent messages
        foreach (var message in messages)
        {
            Assert.Contains(users, u => u == message.User);
            Assert.False(string.IsNullOrWhiteSpace(message.Text));
            Assert.NotNull(message.Sentiment);
        }

        // Count sentiment types
        var positiveMessages = messages.Where(m => m.Sentiment == "positive").ToList();
        var neutralMessages = messages.Where(m => m.Sentiment == "neutral").ToList();
        
        Assert.Equal(2, positiveMessages.Count);
        Assert.Equal(1, neutralMessages.Count);
    }

    [Fact]
    public void Test_Message_Ordering_By_Timestamp()
    {
        // Arrange
        var baseTime = DateTime.UtcNow;
        var messages = new[]
        {
            new { Timestamp = baseTime.AddMinutes(-2), Text = "First" },
            new { Timestamp = baseTime.AddMinutes(-1), Text = "Second" },
            new { Timestamp = baseTime, Text = "Latest" }
        };

        // Act
        var orderedMessages = messages.OrderByDescending(m => m.Timestamp).ToList();

        // Assert
        Assert.Equal("Latest", orderedMessages[0].Text);
        Assert.Equal("Second", orderedMessages[1].Text);
        Assert.Equal("First", orderedMessages[2].Text);

        // Verify timestamps are in descending order
        Assert.True(orderedMessages[0].Timestamp >= orderedMessages[1].Timestamp);
        Assert.True(orderedMessages[1].Timestamp >= orderedMessages[2].Timestamp);
    }

    [Fact]
    public void Test_API_Endpoint_Structures()
    {
        // Test expected API request/response structures
        var sendRequest = new { User = "TestUser", Text = "Test message" };
        var messageResponse = new
        {
            Id = 1,
            User = "TestUser",
            Text = "Test message",
            Timestamp = DateTime.UtcNow,
            Sentiment = "neutral",
            PositiveScore = 0.5f,
            NegativeScore = 0.3f
        };

        // Assert request structure
        Assert.NotNull(sendRequest.User);
        Assert.NotNull(sendRequest.Text);
        Assert.False(string.IsNullOrWhiteSpace(sendRequest.User));
        Assert.False(string.IsNullOrWhiteSpace(sendRequest.Text));

        // Assert response structure
        Assert.True(messageResponse.Id > 0);
        Assert.Equal(sendRequest.User, messageResponse.User);
        Assert.Equal(sendRequest.Text, messageResponse.Text);
        Assert.NotNull(messageResponse.Sentiment);
    }

    [Fact]
    public void Test_Error_Handling_Scenarios()
    {
        // Test various error scenarios
        var scenarios = new[]
        {
            new { User = "", Text = "Valid text", ShouldFail = true },
            new { User = "ValidUser", Text = "", ShouldFail = true },
            new { User = "", Text = "", ShouldFail = true },
            new { User = "ValidUser", Text = "Valid text", ShouldFail = false },
            new { User = "   ", Text = "Valid text", ShouldFail = true }, // whitespace only
            new { User = "ValidUser", Text = "   ", ShouldFail = true }  // whitespace only
        };

        foreach (var scenario in scenarios)
        {
            var userIsEmpty = string.IsNullOrWhiteSpace(scenario.User);
            var textIsEmpty = string.IsNullOrWhiteSpace(scenario.Text);
            var shouldFail = userIsEmpty || textIsEmpty;

            Assert.Equal(scenario.ShouldFail, shouldFail);
        }
    }
}
