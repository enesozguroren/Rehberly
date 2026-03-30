FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Rehberly.ProfileService/Rehberly.ProfileService.csproj", "Rehberly.ProfileService/"]
COPY ["Rehberly.Shared/Rehberly.Shared.csproj", "Rehberly.Shared/"]
RUN dotnet restore "Rehberly.ProfileService/Rehberly.ProfileService.csproj"
COPY . .
WORKDIR "/src/Rehberly.ProfileService"
RUN dotnet publish "Rehberly.ProfileService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Rehberly.ProfileService.dll"]