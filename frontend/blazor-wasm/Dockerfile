FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["frontend/blazor-wasm/frontend-blazor-wasm.csproj", "frontend/blazor-wasm/"]
RUN dotnet restore "./frontend/blazor-wasm/frontend-blazor-wasm.csproj"
COPY . .
WORKDIR "/src/frontend/blazor-wasm"
RUN dotnet build "./frontend-blazor-wasm.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./frontend-blazor-wasm.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "frontend-blazor-wasm.dll"]
