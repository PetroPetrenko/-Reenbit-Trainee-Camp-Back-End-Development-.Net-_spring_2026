namespace backend_wasm.Domain.Entities;

public class Message
{
    public int Id { get; set; }
    public string User { get; set; } = default!;
    public string Text { get; set; } = default!;
    public DateTime Timestamp { get; set; }
    public string Sentiment { get; set; } = "neutral";
    public float PositiveScore { get; set; }
    public float NegativeScore { get; set; }
}
