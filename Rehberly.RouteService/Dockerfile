FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Rehberly.RouteService/Rehberly.RouteService.csproj", "Rehberly.RouteService/"]
COPY ["Rehberly.Shared/Rehberly.Shared.csproj", "Rehberly.Shared/"]
RUN dotnet restore "Rehberly.RouteService/Rehberly.RouteService.csproj"
COPY . .
WORKDIR "/src/Rehberly.RouteService"
RUN dotnet publish "Rehberly.RouteService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Rehberly.RouteService.dll"]