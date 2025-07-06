# Build stage
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# Copy project files
COPY src/ ./

# Restore dependencies
RUN dotnet restore "Readarr.sln"

# Build the application
RUN dotnet publish "Readarr.sln" -c Release -o /app/publish --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Copy published app
COPY --from=build /app/publish .

# Create directories
RUN mkdir -p /config /books /downloads

# Set permissions
RUN chown -R 1000:1000 /app /config /books /downloads

# Expose port
EXPOSE 8787

# Set user
USER 1000:1000

# Start the application
ENTRYPOINT ["dotnet", "Readarr.dll"]
