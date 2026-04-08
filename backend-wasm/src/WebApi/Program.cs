using backend_wasm.Infrastructure.Db;
using backend_wasm.Application.Interfaces;
using backend_wasm.Application.Services;
using backend_wasm.Infrastructure.Repositories;
using backend_wasm.WebApi.Hubs;
using Microsoft.EntityFrameworkCore;
using Azure;
using Azure.AI.TextAnalytics;
using Microsoft.AspNetCore.ResponseCompression;
using Microsoft.AspNetCore.Cors;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

// 🔹 Add EF Core (Azure SQL)
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// 🔹 SignalR + compression for better WebSocket perf
builder.Services.AddSignalR();
builder.Services.AddResponseCompression(opts =>
{
    opts.MimeTypes = ResponseCompressionDefaults.MimeTypes.Concat(new[] { "application/octet-stream" });
});

// 🔹 Cognitive Service client
builder.Services.AddSingleton<TextAnalyticsClient>(sp =>
{
    var endpoint = builder.Configuration["AzureTextAnalytics:Endpoint"];
    var key = builder.Configuration["AzureTextAnalytics:Key"];
    
    if (string.IsNullOrEmpty(endpoint) || string.IsNullOrEmpty(key))
    {
        // Return a mock client for development
        return new TextAnalyticsClient(new Uri("https://localhost"), new AzureKeyCredential("mock"));
    }
    
    return new TextAnalyticsClient(new Uri(endpoint), new AzureKeyCredential(key));
});

// 🔹 Services (SOLID)
builder.Services.AddScoped<IChatService, ChatService>();
builder.Services.AddScoped<ISentimentService, SentimentService>();
builder.Services.AddScoped<IMessageRepository, MessageRepository>();
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();

// 🔹 Controllers + OpenAPI
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// 🔹 CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// 🔹 Blazor WASM hosting
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

var app = builder.Build();

app.UseResponseCompression();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");

app.UseBlazorFrameworkFiles();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllers();
app.MapHub<ChatHub>("/chathub");
app.MapFallbackToFile("index.html");

app.Run();
