FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Rehberly.AuthService/Rehberly.AuthService.csproj", "Rehberly.AuthService/"]
COPY ["Rehberly.Shared/Rehberly.Shared.csproj", "Rehberly.Shared/"]
RUN dotnet restore "Rehberly.AuthService/Rehberly.AuthService.csproj"
COPY . .
WORKDIR "/src/Rehberly.AuthService"
RUN dotnet publish "Rehberly.AuthService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Rehberly.AuthService.dll"]