# Use the official .NET Core SDK image as the base image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

# Create a new non-root user with specific UID and GID
RUN groupadd -g 2000 newapp && useradd -m -u 2000 -g 2000 newapp

# Set the working directory and copy the project files
COPY . ./

# Switch to the new non-root user
USER newapp

# Install Node.js and other dependencies
RUN apt-get update \
    && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get -y install nodejs

# Restore, build, and publish the application
RUN dotnet restore
RUN dotnet build "dotnet6.csproj" -c Release
RUN dotnet publish "dotnet6.csproj" -c Release -o publish


FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base

# Copy the published files from the build stage
COPY --from=build /app/publish .

# Set the environment variable for ASP.NET Core URLs
ENV ASPNETCORE_URLS http://*:5000

# Expose the port
EXPOSE 5000

# Set the entry point command
ENTRYPOINT ["dotnet", "dotnet6.dll"]
