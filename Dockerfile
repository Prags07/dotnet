# Use the official .NET Core SDK image as the base image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

# Install Node.js and other dependencies
RUN apt-get update \
    && apt-get -y install curl \
    && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get -y install nodejs

# Create a new non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Set the working directory and copy the project files
WORKDIR /app
COPY . ./

# Create the necessary directories
RUN mkdir -p /app/.nuget \
    && mkdir -p /app/publish

# Switch to the non-root user
RUN chown -R appuser:appgroup /app
USER appuser

# Restore, build, and publish the application
RUN dotnet restore /app/dotnet6.csproj
RUN dotnet build /app/dotnet6.csproj -c Release
RUN dotnet publish /app/dotnet6.csproj -c Release -o /app/publish


# Use the official .NET Core runtime image as the base image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base

# Set the working directory
WORKDIR /app

# Copy the published files from the build stage
COPY --from=build /app/publish .

# Set the environment variable for ASP.NET Core URLs
ENV ASPNETCORE_URLS http://*:5000

# Expose the port
EXPOSE 5000

# Set the entry point command
ENTRYPOINT ["dotnet", "dotnet6.dll"]
