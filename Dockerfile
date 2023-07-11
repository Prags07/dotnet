# Use the official .NET Core SDK image as the base image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

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

RUN groupadd -r pragnya && \
    useradd -r -g pragnya -s /bin/false pragnya && \
    chown -R pragnya:pragnya /app

USER pragnya

# Expose the port
EXPOSE 5000

# Set the entry point command
ENTRYPOINT ["dotnet", "dotnet6.dll"]
