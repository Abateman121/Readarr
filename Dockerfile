# Build stage
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# Copy source files
COPY src/ ./

# Restore dependencies for the main Readarr project
WORKDIR /src/Readarr
RUN dotnet restore "Readarr.csproj"

# Build and publish the application
RUN dotnet publish "Readarr.csproj" -c Release -o /app/publish --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    sqlite3 \
    mediainfo \
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

# Set environment variables
ENV READARR__INSTANCENAME="Readarr" \
    READARR__BRANCH="develop"

# Start the application
ENTRYPOINT ["dotnet", "Readarr.dll"]
